import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../families/application/family_controller.dart';
import '../data/local_shopping_repository.dart';
import '../data/shopping_repository.dart';
import '../domain/category_classifier.dart';
import '../domain/product_category_preference.dart';
import '../domain/recurring_product.dart';
import '../domain/shopping_category.dart';
import '../domain/shopping_item.dart';

class ShoppingState {
  const ShoppingState({
    this.items = const <ShoppingItem>[],
    this.recurringProducts = const <RecurringProduct>[],
    this.categoryPreferences = const <ProductCategoryPreference>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ShoppingItem> items;
  final List<RecurringProduct> recurringProducts;
  final List<ProductCategoryPreference> categoryPreferences;
  final bool isLoading;
  final String? errorMessage;
}

class ShoppingController extends StateNotifier<ShoppingState> {
  ShoppingController(this._repository) : super(const ShoppingState()) {
    load();
  }

  final ShoppingRepository _repository;

  Future<void> load() async {
    state = const ShoppingState(isLoading: true);
    try {
      final List<ShoppingItem> items = await _repository.loadItems();
      final List<RecurringProduct> recurring =
          await _repository.loadRecurringProducts();
      final List<ProductCategoryPreference> preferences =
          await _repository.loadCategoryPreferences();
      state = ShoppingState(
        items: items,
        recurringProducts: recurring,
        categoryPreferences: preferences,
      );
    } catch (_) {
      state = const ShoppingState(
        errorMessage: 'לא הצלחנו לטעון את רשימת הקניות.',
      );
    }
  }

  Future<bool> addItem({
    required String familyId,
    required String name,
    required String quantity,
    required String note,
    ShoppingCategory? category,
  }) async {
    final String normalized = name.trim();
    if (normalized.length < 2) {
      return false;
    }

    final String normalizedKey = normalized.toLowerCase();
    final ShoppingCategory preferredCategory = category ??
        _preferredCategory(normalizedKey) ??
        CategoryClassifier.classify(normalized);

    final int duplicateIndex = state.items.indexWhere(
      (ShoppingItem item) =>
          item.familyId == familyId &&
          !item.isChecked &&
          item.name.toLowerCase() == normalizedKey,
    );

    if (duplicateIndex != -1) {
      final ShoppingItem existing = state.items[duplicateIndex];
      final String mergedQuantity =
          _mergeQuantities(existing.quantity, quantity.trim());
      final List<ShoppingItem> updated = List<ShoppingItem>.from(state.items)
        ..[duplicateIndex] = existing.copyWith(
          quantity: mergedQuantity,
          note: note.trim().isEmpty ? existing.note : note.trim(),
          category: preferredCategory,
        );
      await _saveItems(updated);
      await _rememberCategory(normalizedKey, preferredCategory);
      return true;
    }

    final DateTime now = DateTime.now();
    final ShoppingItem item = ShoppingItem(
      id: now.microsecondsSinceEpoch.toString(),
      familyId: familyId,
      name: normalized,
      quantity: quantity.trim(),
      note: note.trim(),
      category: preferredCategory,
      isChecked: false,
      createdAt: now,
    );

    await _saveItems(<ShoppingItem>[...state.items, item]);
    await _rememberCategory(normalizedKey, preferredCategory);
    return true;
  }

  Future<void> updateItem({
    required String itemId,
    required String name,
    required String quantity,
    required String note,
    required ShoppingCategory category,
  }) async {
    final String normalized = name.trim();
    if (normalized.length < 2) {
      return;
    }

    final List<ShoppingItem> updated = state.items.map(
      (ShoppingItem item) {
        if (item.id != itemId) {
          return item;
        }
        return item.copyWith(
          name: normalized,
          quantity: quantity.trim(),
          note: note.trim(),
          category: category,
        );
      },
    ).toList();

    await _saveItems(updated);
    await _rememberCategory(normalized.toLowerCase(), category);
  }

  Future<void> toggleItem(String itemId) async {
    await _saveItems(
      state.items.map((ShoppingItem item) {
        return item.id == itemId
            ? item.copyWith(isChecked: !item.isChecked)
            : item;
      }).toList(),
    );
  }

  Future<void> deleteItem(String itemId) async {
    await _saveItems(
      state.items.where((ShoppingItem item) => item.id != itemId).toList(),
    );
  }

  Future<void> clearChecked(String familyId) async {
    await _saveItems(
      state.items
          .where(
            (ShoppingItem item) => item.familyId != familyId || !item.isChecked,
          )
          .toList(),
    );
  }

  Future<bool> addRecurringProduct({
    required String familyId,
    required String name,
    required String quantity,
    required ShoppingCategory category,
    required RecurrenceCadence cadence,
  }) async {
    if (name.trim().length < 2) {
      return false;
    }

    final DateTime now = DateTime.now();
    final RecurringProduct product = RecurringProduct(
      id: now.microsecondsSinceEpoch.toString(),
      familyId: familyId,
      name: name.trim(),
      quantity: quantity.trim(),
      category: category,
      cadence: cadence,
      lastAddedAt: null,
    );

    await _saveRecurring(
      <RecurringProduct>[...state.recurringProducts, product],
    );
    return true;
  }

  Future<void> deleteRecurringProduct(String productId) async {
    await _saveRecurring(
      state.recurringProducts
          .where(
            (RecurringProduct product) => product.id != productId,
          )
          .toList(),
    );
  }

  Future<int> addDueRecurringProducts(String familyId) async {
    final List<RecurringProduct> due = state.recurringProducts
        .where(
          (RecurringProduct product) =>
              product.familyId == familyId && product.isDue,
        )
        .toList();

    int added = 0;
    for (final RecurringProduct product in due) {
      final bool success = await addItem(
        familyId: familyId,
        name: product.name,
        quantity: product.quantity,
        note: '',
        category: product.category,
      );
      if (success) {
        added++;
      }
    }

    if (added > 0) {
      final DateTime now = DateTime.now();
      await _saveRecurring(
        state.recurringProducts.map((RecurringProduct product) {
          if (due.any(
            (RecurringProduct dueProduct) => dueProduct.id == product.id,
          )) {
            return product.copyWith(lastAddedAt: now);
          }
          return product;
        }).toList(),
      );
    }
    return added;
  }

  Future<void> _saveItems(List<ShoppingItem> items) async {
    await _repository.saveItems(items);
    state = ShoppingState(
      items: items,
      recurringProducts: state.recurringProducts,
      categoryPreferences: state.categoryPreferences,
    );
  }

  Future<void> _saveRecurring(
    List<RecurringProduct> products,
  ) async {
    await _repository.saveRecurringProducts(products);
    state = ShoppingState(
      items: state.items,
      recurringProducts: products,
      categoryPreferences: state.categoryPreferences,
    );
  }

  ShoppingCategory? _preferredCategory(String productName) {
    for (final ProductCategoryPreference preference
        in state.categoryPreferences) {
      if (preference.productName == productName) {
        return preference.category;
      }
    }
    return null;
  }

  Future<void> _rememberCategory(
    String productName,
    ShoppingCategory category,
  ) async {
    final List<ProductCategoryPreference> updated = state.categoryPreferences
        .where(
          (ProductCategoryPreference preference) =>
              preference.productName != productName,
        )
        .toList()
      ..add(
        ProductCategoryPreference(
          productName: productName,
          category: category,
        ),
      );

    await _repository.saveCategoryPreferences(updated);
    state = ShoppingState(
      items: state.items,
      recurringProducts: state.recurringProducts,
      categoryPreferences: updated,
    );
  }

  String _mergeQuantities(String first, String second) {
    final int? firstNumber = int.tryParse(first.trim());
    final int? secondNumber = int.tryParse(second.trim());
    if (firstNumber != null && secondNumber != null) {
      return (firstNumber + secondNumber).toString();
    }
    if (first.trim().isEmpty) {
      return second.trim();
    }
    if (second.trim().isEmpty) {
      return first.trim();
    }
    if (first.trim() == second.trim()) {
      return first.trim();
    }
    return '${first.trim()} + ${second.trim()}';
  }
}

final Provider<ShoppingRepository> shoppingRepositoryProvider =
    Provider<ShoppingRepository>(
  (Ref ref) => LocalShoppingRepository(),
);

final StateNotifierProvider<ShoppingController, ShoppingState>
    shoppingControllerProvider =
    StateNotifierProvider<ShoppingController, ShoppingState>(
  (Ref ref) => ShoppingController(
    ref.watch(shoppingRepositoryProvider),
  ),
);

final Provider<List<ShoppingItem>> activeFamilyShoppingItemsProvider =
    Provider<List<ShoppingItem>>((Ref ref) {
  final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
  final List<ShoppingItem> items = ref.watch(shoppingControllerProvider).items;

  if (familyId == null) {
    return <ShoppingItem>[];
  }

  final List<ShoppingItem> filtered =
      items.where((ShoppingItem item) => item.familyId == familyId).toList()
        ..sort((ShoppingItem first, ShoppingItem second) {
          final int categoryOrder =
              first.category.sortOrder.compareTo(second.category.sortOrder);
          if (categoryOrder != 0) {
            return categoryOrder;
          }
          if (first.isChecked != second.isChecked) {
            return first.isChecked ? 1 : -1;
          }
          return first.createdAt.compareTo(second.createdAt);
        });
  return filtered;
});

final Provider<List<RecurringProduct>> activeFamilyRecurringProductsProvider =
    Provider<List<RecurringProduct>>((Ref ref) {
  final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
  final List<RecurringProduct> products =
      ref.watch(shoppingControllerProvider).recurringProducts;

  if (familyId == null) {
    return <RecurringProduct>[];
  }

  return products
      .where(
        (RecurringProduct product) => product.familyId == familyId,
      )
      .toList();
});
