import '../domain/product_category_preference.dart';
import '../domain/recurring_product.dart';
import '../domain/shopping_item.dart';
import '../domain/shopping_list.dart';

abstract interface class ShoppingRepository {
  Future<List<ShoppingItem>> loadItems();
  Future<void> saveItems(List<ShoppingItem> items);
  Future<List<RecurringProduct>> loadRecurringProducts();
  Future<void> saveRecurringProducts(List<RecurringProduct> products);
  Future<List<ProductCategoryPreference>> loadCategoryPreferences();
  Future<void> saveCategoryPreferences(
    List<ProductCategoryPreference> preferences,
  );
  Future<List<ShoppingList>> loadLists();
  Future<void> saveLists(List<ShoppingList> lists);
  Future<String?> loadSelectedListId();
  Future<void> saveSelectedListId(String? listId);
}
