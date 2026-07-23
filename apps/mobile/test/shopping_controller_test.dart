import 'package:family_os/features/shopping/application/shopping_controller.dart';
import 'package:family_os/features/shopping/data/shopping_repository.dart';
import 'package:family_os/features/shopping/domain/product_category_preference.dart';
import 'package:family_os/features/shopping/domain/recurring_product.dart';
import 'package:family_os/features/shopping/domain/shopping_category.dart';
import 'package:family_os/features/shopping/domain/shopping_item.dart';
import 'package:family_os/features/shopping/domain/shopping_list.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryShoppingRepository implements ShoppingRepository {
  List<ShoppingItem> items = <ShoppingItem>[];
  List<RecurringProduct> recurring = <RecurringProduct>[];
  List<ShoppingList> lists = <ShoppingList>[];
  String? selectedListId;

  @override
  Future<List<ShoppingItem>> loadItems() async => items;
  @override
  Future<List<RecurringProduct>> loadRecurringProducts() async => recurring;
  @override
  Future<List<ProductCategoryPreference>> loadCategoryPreferences() async =>
      <ProductCategoryPreference>[];
  @override
  Future<List<ShoppingList>> loadLists() async => lists;
  @override
  Future<String?> loadSelectedListId() async => selectedListId;
  @override
  Future<void> saveItems(List<ShoppingItem> value) async => items = value;
  @override
  Future<void> saveRecurringProducts(
    List<RecurringProduct> value,
  ) async =>
      recurring = value;
  @override
  Future<void> saveCategoryPreferences(
    List<ProductCategoryPreference> preferences,
  ) async {}
  @override
  Future<void> saveLists(List<ShoppingList> value) async => lists = value;
  @override
  Future<void> saveSelectedListId(String? value) async =>
      selectedListId = value;
}

void main() {
  test('creates multiple lists and selects them', () async {
    final MemoryShoppingRepository repository = MemoryShoppingRepository();
    final ShoppingController controller = ShoppingController(repository);
    await controller.load();
    await controller.ensureFamilyReady('f1');
    expect(controller.state.lists, hasLength(1));

    expect(await controller.createList('f1', 'פארם'), isTrue);
    expect(controller.state.lists, hasLength(2));
    expect(
      controller.state.lists
          .firstWhere(
              (ShoppingList list) => list.id == controller.state.selectedListId)
          .name,
      'פארם',
    );
  });

  test('shopping item lifecycle and checked cleanup work', () async {
    final MemoryShoppingRepository repository = MemoryShoppingRepository();
    final ShoppingController controller = ShoppingController(repository);
    await controller.load();
    await controller.ensureFamilyReady('f1');

    expect(
      await controller.addItem(
        familyId: 'f1',
        name: 'מלפפון',
        quantity: '2',
        note: '',
      ),
      isTrue,
    );
    expect(controller.state.items.single.category, ShoppingCategory.vegetables);

    final String itemId = controller.state.items.single.id;
    await controller.toggleItem(itemId);
    await controller.clearChecked('f1');
    expect(controller.state.items, isEmpty);
  });

  test('automatic recurring products are added when due', () async {
    final MemoryShoppingRepository repository = MemoryShoppingRepository();
    final ShoppingController controller = ShoppingController(repository);
    await controller.load();
    await controller.ensureFamilyReady('f1');

    await controller.addRecurringProduct(
      familyId: 'f1',
      name: 'חלב',
      quantity: '2',
      category: ShoppingCategory.dairy,
      cadence: RecurrenceCadence.weekly,
      autoAdd: true,
    );

    await controller.ensureFamilyReady('f1');
    expect(controller.state.items, hasLength(1));
    expect(controller.state.items.single.name, 'חלב');
  });

  test('merges duplicate numeric quantities inside one list', () async {
    final MemoryShoppingRepository repository = MemoryShoppingRepository();
    final ShoppingController controller = ShoppingController(repository);
    await controller.load();
    await controller.ensureFamilyReady('f1');

    await controller.addItem(
      familyId: 'f1',
      name: 'חלב',
      quantity: '2',
      note: '',
    );
    await controller.addItem(
      familyId: 'f1',
      name: 'חלב',
      quantity: '1',
      note: '',
    );

    expect(controller.state.items, hasLength(1));
    expect(controller.state.items.single.quantity, '3');
  });
}
