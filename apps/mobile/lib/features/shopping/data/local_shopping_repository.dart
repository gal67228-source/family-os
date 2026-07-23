import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/product_category_preference.dart';
import '../domain/recurring_product.dart';
import '../domain/shopping_item.dart';
import '../domain/shopping_list.dart';
import 'shopping_repository.dart';

class LocalShoppingRepository implements ShoppingRepository {
  static const String _itemsKey = 'family_os_shopping_items';
  static const String _recurringKey = 'family_os_recurring_products';
  static const String _preferencesKey = 'family_os_category_preferences';
  static const String _listsKey = 'family_os_shopping_lists';
  static const String _selectedListKey = 'family_os_selected_shopping_list';

  Future<List<T>> _loadList<T>(
    String key,
    T Function(Map<String, Object?>) fromJson,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return <T>[];
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) return <T>[];
    return decoded.whereType<Map<String, Object?>>().map(fromJson).toList();
  }

  Future<void> _saveList(
    String key,
    List<Map<String, Object?>> values,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(values));
  }

  @override
  Future<List<ShoppingItem>> loadItems() =>
      _loadList(_itemsKey, ShoppingItem.fromJson);

  @override
  Future<void> saveItems(List<ShoppingItem> items) =>
      _saveList(_itemsKey, items.map((e) => e.toJson()).toList());

  @override
  Future<List<RecurringProduct>> loadRecurringProducts() =>
      _loadList(_recurringKey, RecurringProduct.fromJson);

  @override
  Future<void> saveRecurringProducts(List<RecurringProduct> products) =>
      _saveList(_recurringKey, products.map((e) => e.toJson()).toList());

  @override
  Future<List<ProductCategoryPreference>> loadCategoryPreferences() =>
      _loadList(_preferencesKey, ProductCategoryPreference.fromJson);

  @override
  Future<void> saveCategoryPreferences(
    List<ProductCategoryPreference> preferences,
  ) =>
      _saveList(_preferencesKey, preferences.map((e) => e.toJson()).toList());

  @override
  Future<List<ShoppingList>> loadLists() =>
      _loadList(_listsKey, ShoppingList.fromJson);

  @override
  Future<void> saveLists(List<ShoppingList> lists) =>
      _saveList(_listsKey, lists.map((e) => e.toJson()).toList());

  @override
  Future<String?> loadSelectedListId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedListKey);
  }

  @override
  Future<void> saveSelectedListId(String? listId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (listId == null) {
      await prefs.remove(_selectedListKey);
    } else {
      await prefs.setString(_selectedListKey, listId);
    }
  }
}
