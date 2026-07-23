import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/product_category_preference.dart';
import '../domain/recurring_product.dart';
import '../domain/shopping_item.dart';
import 'shopping_repository.dart';

class LocalShoppingRepository implements ShoppingRepository {
  static const String _itemsKey = 'family_os_shopping_items';
  static const String _recurringKey = 'family_os_recurring_products';
  static const String _preferencesKey = 'family_os_category_preferences';

  @override
  Future<List<ShoppingItem>> loadItems() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_itemsKey);
    if (raw == null || raw.isEmpty) {
      return <ShoppingItem>[];
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) {
      return <ShoppingItem>[];
    }
    return decoded
        .whereType<Map<String, Object?>>()
        .map(ShoppingItem.fromJson)
        .toList();
  }

  @override
  Future<void> saveItems(List<ShoppingItem> items) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _itemsKey,
      jsonEncode(
        items.map((ShoppingItem item) => item.toJson()).toList(),
      ),
    );
  }

  @override
  Future<List<RecurringProduct>> loadRecurringProducts() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_recurringKey);
    if (raw == null || raw.isEmpty) {
      return <RecurringProduct>[];
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) {
      return <RecurringProduct>[];
    }
    return decoded
        .whereType<Map<String, Object?>>()
        .map(RecurringProduct.fromJson)
        .toList();
  }

  @override
  Future<void> saveRecurringProducts(
    List<RecurringProduct> products,
  ) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _recurringKey,
      jsonEncode(
        products.map((RecurringProduct product) => product.toJson()).toList(),
      ),
    );
  }

  @override
  Future<List<ProductCategoryPreference>> loadCategoryPreferences() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_preferencesKey);
    if (raw == null || raw.isEmpty) {
      return <ProductCategoryPreference>[];
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) {
      return <ProductCategoryPreference>[];
    }
    return decoded
        .whereType<Map<String, Object?>>()
        .map(ProductCategoryPreference.fromJson)
        .toList();
  }

  @override
  Future<void> saveCategoryPreferences(
    List<ProductCategoryPreference> values,
  ) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _preferencesKey,
      jsonEncode(
        values
            .map(
              (ProductCategoryPreference value) => value.toJson(),
            )
            .toList(),
      ),
    );
  }
}
