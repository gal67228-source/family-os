import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../families/application/family_controller.dart';
import '../data/local_shopping_repository.dart';
import '../data/shopping_repository.dart';
import '../domain/category_classifier.dart';
import '../domain/product_category_preference.dart';
import '../domain/recurring_product.dart';
import '../domain/shopping_category.dart';
import '../domain/shopping_item.dart';
import '../domain/shopping_list.dart';

class ShoppingState {
  const ShoppingState({
    this.items = const <ShoppingItem>[],
    this.recurringProducts = const <RecurringProduct>[],
    this.categoryPreferences = const <ProductCategoryPreference>[],
    this.lists = const <ShoppingList>[],
    this.selectedListId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ShoppingItem> items;
  final List<RecurringProduct> recurringProducts;
  final List<ProductCategoryPreference> categoryPreferences;
  final List<ShoppingList> lists;
  final String? selectedListId;
  final bool isLoading;
  final String? errorMessage;

  ShoppingState copyWith({
    List<ShoppingItem>? items,
    List<RecurringProduct>? recurringProducts,
    List<ProductCategoryPreference>? categoryPreferences,
    List<ShoppingList>? lists,
    String? selectedListId,
    bool clearSelectedList = false,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ShoppingState(
      items: items ?? this.items,
      recurringProducts: recurringProducts ?? this.recurringProducts,
      categoryPreferences: categoryPreferences ?? this.categoryPreferences,
      lists: lists ?? this.lists,
      selectedListId:
          clearSelectedList ? null : selectedListId ?? this.selectedListId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ShoppingController extends StateNotifier<ShoppingState> {
  ShoppingController(this._repository) : super(const ShoppingState()) {
    load();
  }

  final ShoppingRepository _repository;

  Future<void> load() async {
    state = const ShoppingState(isLoading: true);
    try {
      state = ShoppingState(
        items: await _repository.loadItems(),
        recurringProducts: await _repository.loadRecurringProducts(),
        categoryPreferences: await _repository.loadCategoryPreferences(),
        lists: await _repository.loadLists(),
        selectedListId: await _repository.loadSelectedListId(),
      );
    } catch (_) {
      state = const ShoppingState(
        errorMessage: 'לא הצלחנו לטעון את רשימות הקניות.',
      );
    }
  }

  Future<void> ensureFamilyReady(String familyId) async {
    List<ShoppingList> lists = state.lists
        .where((ShoppingList list) => list.familyId == familyId)
        .toList();

    if (lists.isEmpty) {
      final ShoppingList defaultList = ShoppingList(
        id: 'list-${DateTime.now().microsecondsSinceEpoch}',
        familyId: familyId,
        name: 'קניות שבועיות',
        createdAt: DateTime.now(),
        sortOrder: 0,
      );
      await _repository.saveLists(<ShoppingList>[
        ...state.lists,
        defaultList,
      ]);
      state = state.copyWith(
        lists: <ShoppingList>[...state.lists, defaultList],
        selectedListId: defaultList.id,
      );
      await _repository.saveSelectedListId(defaultList.id);
      lists = <ShoppingList>[defaultList];
    }

    final String selected = lists.any(
      (ShoppingList list) => list.id == state.selectedListId,
    )
        ? state.selectedListId!
        : lists.first.id;

    if (selected != state.selectedListId) {
      state = state.copyWith(selectedListId: selected);
      await _repository.saveSelectedListId(selected);
    }

    final List<ShoppingItem> migratedItems = state.items
        .map((ShoppingItem item) =>
            item.familyId == familyId && item.listId.isEmpty
                ? item.copyWith(listId: selected)
                : item)
        .toList();
    final List<RecurringProduct> migratedRecurring = state.recurringProducts
        .map((RecurringProduct product) =>
            product.familyId == familyId && product.listId.isEmpty
                ? product.copyWith(listId: selected)
                : product)
        .toList();

    await _repository.saveItems(migratedItems);
    await _repository.saveRecurringProducts(migratedRecurring);
    state = state.copyWith(
      items: migratedItems,
      recurringProducts: migratedRecurring,
    );

    await addDueRecurringProducts(
      familyId,
      automaticOnly: true,
    );
  }

  Future<void> selectList(String listId) async {
    state = state.copyWith(selectedListId: listId);
    await _repository.saveSelectedListId(listId);
  }

  Future<bool> createList(String familyId, String name) async {
    if (name.trim().length < 2) return false;
    final int nextOrder = state.lists
            .where((ShoppingList list) => list.familyId == familyId)
            .fold<int>(
              -1,
              (int maxOrder, ShoppingList list) =>
                  list.sortOrder > maxOrder ? list.sortOrder : maxOrder,
            ) +
        1;
    final ShoppingList list = ShoppingList(
      id: 'list-${DateTime.now().microsecondsSinceEpoch}',
      familyId: familyId,
      name: name.trim(),
      createdAt: DateTime.now(),
      sortOrder: nextOrder,
    );
    final List<ShoppingList> updated = <ShoppingList>[...state.lists, list];
    await _repository.saveLists(updated);
    state = state.copyWith(lists: updated, selectedListId: list.id);
    await _repository.saveSelectedListId(list.id);
    return true;
  }

  Future<void> renameList(String listId, String name) async {
    if (name.trim().length < 2) return;
    final List<ShoppingList> updated = state.lists
        .map((ShoppingList list) =>
            list.id == listId ? list.copyWith(name: name.trim()) : list)
        .toList();
    await _repository.saveLists(updated);
    state = state.copyWith(lists: updated);
  }

  Future<bool> archiveList(String familyId, String listId) async {
    final List<ShoppingList> activeLists = state.lists
        .where(
          (ShoppingList list) => list.familyId == familyId && !list.isArchived,
        )
        .toList();
    if (activeLists.length <= 1) {
      return false;
    }

    final List<ShoppingList> updated = state.lists.map(
      (ShoppingList list) {
        return list.id == listId ? list.copyWith(isArchived: true) : list;
      },
    ).toList();

    final List<ShoppingList> remainingLists = updated
        .where(
          (ShoppingList list) => list.familyId == familyId && !list.isArchived,
        )
        .toList()
      ..sort(
        (ShoppingList first, ShoppingList second) =>
            first.sortOrder.compareTo(second.sortOrder),
      );

    final String nextListId = remainingLists.first.id;

    await _repository.saveLists(updated);
    await _repository.saveSelectedListId(nextListId);
    state = state.copyWith(
      lists: updated,
      selectedListId: nextListId,
    );
    return true;
  }

  Future<void> restoreList(String listId) async {
    final List<ShoppingList> updated = state.lists.map(
      (ShoppingList list) {
        return list.id == listId ? list.copyWith(isArchived: false) : list;
      },
    ).toList();
    await _repository.saveLists(updated);
    state = state.copyWith(lists: updated);
  }

  Future<void> reorderLists(
    String familyId,
    int oldIndex,
    int newIndex,
  ) async {
    final List<ShoppingList> activeLists = state.lists
        .where(
          (ShoppingList list) => list.familyId == familyId && !list.isArchived,
        )
        .toList()
      ..sort(
        (ShoppingList first, ShoppingList second) =>
            first.sortOrder.compareTo(second.sortOrder),
      );

    if (oldIndex < 0 ||
        oldIndex >= activeLists.length ||
        newIndex < 0 ||
        newIndex >= activeLists.length) {
      return;
    }

    final ShoppingList moved = activeLists.removeAt(oldIndex);
    activeLists.insert(newIndex, moved);

    final Map<String, int> orders = <String, int>{
      for (int index = 0; index < activeLists.length; index++)
        activeLists[index].id: index,
    };

    final List<ShoppingList> updated = state.lists.map(
      (ShoppingList list) {
        final int? order = orders[list.id];
        return order == null ? list : list.copyWith(sortOrder: order);
      },
    ).toList();

    await _repository.saveLists(updated);
    state = state.copyWith(lists: updated);
  }

  Future<bool> addItem({
    required String familyId,
    required String name,
    required String quantity,
    required String note,
    ShoppingCategory? category,
    String? listId,
  }) async {
    final String normalized = name.trim();
    if (normalized.length < 2) return false;
    final String targetList = listId ?? state.selectedListId ?? '';
    if (targetList.isEmpty) return false;

    final String key = normalized.toLowerCase();
    final ShoppingCategory selectedCategory = category ??
        _preferredCategory(key) ??
        CategoryClassifier.classify(normalized);

    final int duplicateIndex = state.items.indexWhere(
      (ShoppingItem item) =>
          item.familyId == familyId &&
          item.listId == targetList &&
          !item.isChecked &&
          item.name.toLowerCase() == key,
    );

    if (duplicateIndex != -1) {
      final ShoppingItem existing = state.items[duplicateIndex];
      final List<ShoppingItem> updated = List<ShoppingItem>.from(state.items)
        ..[duplicateIndex] = existing.copyWith(
          quantity: _mergeQuantities(existing.quantity, quantity.trim()),
          note: note.trim().isEmpty ? existing.note : note.trim(),
          category: selectedCategory,
        );
      await _saveItems(updated);
      await _rememberCategory(key, selectedCategory);
      return true;
    }

    final ShoppingItem item = ShoppingItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      familyId: familyId,
      listId: targetList,
      name: normalized,
      quantity: quantity.trim(),
      note: note.trim(),
      category: selectedCategory,
      isChecked: false,
      createdAt: DateTime.now(),
    );
    await _saveItems(<ShoppingItem>[...state.items, item]);
    await _rememberCategory(key, selectedCategory);
    return true;
  }

  Future<void> updateItem({
    required String itemId,
    required String name,
    required String quantity,
    required String note,
    required ShoppingCategory category,
  }) async {
    if (name.trim().length < 2) return;
    final List<ShoppingItem> updated = state.items.map((ShoppingItem item) {
      return item.id == itemId
          ? item.copyWith(
              name: name.trim(),
              quantity: quantity.trim(),
              note: note.trim(),
              category: category,
            )
          : item;
    }).toList();
    await _saveItems(updated);
    await _rememberCategory(name.trim().toLowerCase(), category);
  }

  Future<void> toggleItem(String itemId) async {
    await _saveItems(state.items.map((ShoppingItem item) {
      return item.id == itemId
          ? item.copyWith(isChecked: !item.isChecked)
          : item;
    }).toList());
  }

  Future<void> deleteItem(String itemId) async {
    await _saveItems(
      state.items.where((ShoppingItem item) => item.id != itemId).toList(),
    );
  }

  Future<void> clearChecked(String familyId, {String? listId}) async {
    final String target = listId ?? state.selectedListId ?? '';
    await _saveItems(state.items.where((ShoppingItem item) {
      return item.familyId != familyId ||
          item.listId != target ||
          !item.isChecked;
    }).toList());
  }

  Future<bool> addRecurringProduct({
    required String familyId,
    required String name,
    required String quantity,
    required ShoppingCategory category,
    required RecurrenceCadence cadence,
    String? listId,
    bool autoAdd = true,
  }) async {
    final String normalizedName = name.trim();
    if (normalizedName.length < 2) return false;

    final String target = listId ?? state.selectedListId ?? '';
    if (target.isEmpty) return false;

    DateTime? addedAt;
    if (autoAdd) {
      final bool added = await addItem(
        familyId: familyId,
        listId: target,
        name: normalizedName,
        quantity: quantity.trim(),
        note: '',
        category: category,
      );
      if (added) {
        addedAt = DateTime.now();
      }
    }

    final RecurringProduct product = RecurringProduct(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      familyId: familyId,
      listId: target,
      name: normalizedName,
      quantity: quantity.trim(),
      category: category,
      cadence: cadence,
      autoAdd: autoAdd,
      lastAddedAt: addedAt,
    );

    await _saveRecurring(<RecurringProduct>[
      ...state.recurringProducts,
      product,
    ]);
    return true;
  }

  Future<void> deleteRecurringProduct(String productId) async {
    await _saveRecurring(state.recurringProducts
        .where((RecurringProduct product) => product.id != productId)
        .toList());
  }

  Future<int> addDueRecurringProducts(
    String familyId, {
    bool automaticOnly = false,
  }) async {
    final List<RecurringProduct> due = state.recurringProducts
        .where(
          (RecurringProduct product) =>
              product.familyId == familyId &&
              product.isDue &&
              (!automaticOnly || product.autoAdd),
        )
        .toList();

    int added = 0;
    final DateTime now = DateTime.now();
    final Set<String> processed = <String>{};

    for (final RecurringProduct product in due) {
      final bool success = await addItem(
        familyId: familyId,
        listId: product.listId,
        name: product.name,
        quantity: product.quantity,
        note: '',
        category: product.category,
      );
      if (success) {
        added++;
        processed.add(product.id);
      }
    }

    if (processed.isNotEmpty) {
      await _saveRecurring(state.recurringProducts
          .map(
            (RecurringProduct product) => processed.contains(product.id)
                ? product.copyWith(lastAddedAt: now)
                : product,
          )
          .toList());
    }
    return added;
  }

  Future<void> _saveItems(List<ShoppingItem> items) async {
    await _repository.saveItems(items);
    state = state.copyWith(items: items);
  }

  Future<void> _saveRecurring(List<RecurringProduct> products) async {
    await _repository.saveRecurringProducts(products);
    state = state.copyWith(recurringProducts: products);
  }

  ShoppingCategory? _preferredCategory(String productName) {
    for (final ProductCategoryPreference preference
        in state.categoryPreferences) {
      if (preference.productName == productName) return preference.category;
    }
    return null;
  }

  Future<void> _rememberCategory(
    String productName,
    ShoppingCategory category,
  ) async {
    final List<ProductCategoryPreference> updated = state.categoryPreferences
        .where((ProductCategoryPreference p) => p.productName != productName)
        .toList()
      ..add(ProductCategoryPreference(
        productName: productName,
        category: category,
      ));
    await _repository.saveCategoryPreferences(updated);
    state = state.copyWith(categoryPreferences: updated);
  }

  String _mergeQuantities(String first, String second) {
    final int? a = int.tryParse(first.trim());
    final int? b = int.tryParse(second.trim());
    if (a != null && b != null) return (a + b).toString();
    if (first.trim().isEmpty) return second.trim();
    if (second.trim().isEmpty) return first.trim();
    return first.trim() == second.trim()
        ? first.trim()
        : '${first.trim()} + ${second.trim()}';
  }
}

final Provider<ShoppingRepository> shoppingRepositoryProvider =
    Provider<ShoppingRepository>((Ref ref) => LocalShoppingRepository());

final StateNotifierProvider<ShoppingController, ShoppingState>
    shoppingControllerProvider =
    StateNotifierProvider<ShoppingController, ShoppingState>(
  (Ref ref) => ShoppingController(ref.watch(shoppingRepositoryProvider)),
);

final Provider<List<ShoppingList>> activeFamilyShoppingListsProvider =
    Provider<List<ShoppingList>>((Ref ref) {
  final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
  if (familyId == null) return <ShoppingList>[];
  final List<ShoppingList> lists = ref
      .watch(shoppingControllerProvider)
      .lists
      .where(
        (ShoppingList list) => list.familyId == familyId && !list.isArchived,
      )
      .toList()
    ..sort(
      (ShoppingList first, ShoppingList second) =>
          first.sortOrder.compareTo(second.sortOrder),
    );
  return lists;
});

final Provider<List<ShoppingList>> archivedFamilyShoppingListsProvider =
    Provider<List<ShoppingList>>((Ref ref) {
  final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
  if (familyId == null) {
    return <ShoppingList>[];
  }
  final List<ShoppingList> lists = ref
      .watch(shoppingControllerProvider)
      .lists
      .where(
        (ShoppingList list) => list.familyId == familyId && list.isArchived,
      )
      .toList()
    ..sort(
      (ShoppingList first, ShoppingList second) =>
          first.sortOrder.compareTo(second.sortOrder),
    );
  return lists;
});

final Provider<ShoppingList?> activeShoppingListProvider =
    Provider<ShoppingList?>((Ref ref) {
  final ShoppingState state = ref.watch(shoppingControllerProvider);
  final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
  if (familyId == null) return null;
  for (final ShoppingList list in state.lists) {
    if (list.familyId == familyId && list.id == state.selectedListId) {
      return list;
    }
  }
  return null;
});

final Provider<List<ShoppingItem>> activeFamilyShoppingItemsProvider =
    Provider<List<ShoppingItem>>((Ref ref) {
  final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
  final String? listId = ref.watch(activeShoppingListProvider)?.id;
  if (familyId == null || listId == null) return <ShoppingItem>[];
  final List<ShoppingItem> items = ref
      .watch(shoppingControllerProvider)
      .items
      .where((ShoppingItem item) =>
          item.familyId == familyId && item.listId == listId)
      .toList()
    ..sort((ShoppingItem a, ShoppingItem b) {
      if (a.category.sortOrder != b.category.sortOrder) {
        return a.category.sortOrder.compareTo(b.category.sortOrder);
      }
      if (a.isChecked != b.isChecked) return a.isChecked ? 1 : -1;
      return a.createdAt.compareTo(b.createdAt);
    });
  return items;
});

final Provider<List<ShoppingItem>> allActiveFamilyShoppingItemsProvider =
    Provider<List<ShoppingItem>>((Ref ref) {
  final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
  if (familyId == null) return <ShoppingItem>[];
  return ref
      .watch(shoppingControllerProvider)
      .items
      .where((ShoppingItem item) => item.familyId == familyId)
      .toList();
});

final Provider<List<RecurringProduct>> activeFamilyRecurringProductsProvider =
    Provider<List<RecurringProduct>>((Ref ref) {
  final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
  if (familyId == null) return <RecurringProduct>[];
  return ref
      .watch(shoppingControllerProvider)
      .recurringProducts
      .where((RecurringProduct product) => product.familyId == familyId)
      .toList();
});
