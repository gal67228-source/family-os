import 'package:family_os/features/shopping/application/shopping_controller.dart';
import 'package:family_os/features/shopping/data/shopping_repository.dart';
import 'package:family_os/features/shopping/domain/recurring_product.dart';
import 'package:family_os/features/shopping/domain/shopping_category.dart';
import 'package:family_os/features/shopping/domain/shopping_item.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryShoppingRepository implements ShoppingRepository {
  List<ShoppingItem> items = <ShoppingItem>[];
  List<RecurringProduct> recurring = <RecurringProduct>[];

  @override
  Future<List<ShoppingItem>> loadItems() async => items;

  @override
  Future<List<RecurringProduct>> loadRecurringProducts() async => recurring;

  @override
  Future<void> saveItems(List<ShoppingItem> value) async {
    items = value;
  }

  @override
  Future<void> saveRecurringProducts(
    List<RecurringProduct> value,
  ) async {
    recurring = value;
  }
}

void main() {
  test('shopping item lifecycle and checked cleanup work', () async {
    final MemoryShoppingRepository repository = MemoryShoppingRepository();
    final ShoppingController controller = ShoppingController(repository);
    await controller.load();

    expect(
      await controller.addItem(
        familyId: 'f1',
        name: 'מלפפון',
        quantity: '2',
        note: '',
      ),
      isTrue,
    );
    expect(
      controller.state.items.single.category,
      ShoppingCategory.vegetables,
    );

    final String itemId = controller.state.items.single.id;
    await controller.toggleItem(itemId);
    expect(controller.state.items.single.isChecked, isTrue);

    await controller.clearChecked('f1');
    expect(controller.state.items, isEmpty);
  });

  test('due recurring products can be added to the list', () async {
    final MemoryShoppingRepository repository = MemoryShoppingRepository();
    final ShoppingController controller = ShoppingController(repository);
    await controller.load();

    await controller.addRecurringProduct(
      familyId: 'f1',
      name: 'חלב',
      quantity: '2',
      category: ShoppingCategory.dairy,
      cadence: RecurrenceCadence.weekly,
    );

    expect(await controller.addDueRecurringProducts('f1'), 1);
    expect(controller.state.items, hasLength(1));
    expect(controller.state.items.single.name, 'חלב');
  });
}
