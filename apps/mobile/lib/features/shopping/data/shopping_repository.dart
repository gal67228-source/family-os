import '../domain/product_category_preference.dart';
import '../domain/recurring_product.dart';
import '../domain/shopping_item.dart';

abstract interface class ShoppingRepository {
  Future<List<ShoppingItem>> loadItems();
  Future<void> saveItems(List<ShoppingItem> items);
  Future<List<RecurringProduct>> loadRecurringProducts();
  Future<void> saveRecurringProducts(List<RecurringProduct> products);
  Future<List<ProductCategoryPreference>> loadCategoryPreferences();
  Future<void> saveCategoryPreferences(
    List<ProductCategoryPreference> preferences,
  );
}
