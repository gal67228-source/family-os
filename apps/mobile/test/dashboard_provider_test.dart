import 'package:family_os/features/dashboard/application/dashboard_provider.dart';
import 'package:family_os/features/families/application/family_controller.dart';
import 'package:family_os/features/families/data/family_repository.dart';
import 'package:family_os/features/families/domain/family_icon.dart';
import 'package:family_os/features/families/domain/family_member.dart';
import 'package:family_os/features/families/domain/family_workspace.dart';
import 'package:family_os/features/shopping/application/shopping_controller.dart';
import 'package:family_os/features/shopping/data/shopping_repository.dart';
import 'package:family_os/features/shopping/domain/product_category_preference.dart';
import 'package:family_os/features/shopping/domain/recurring_product.dart';
import 'package:family_os/features/shopping/domain/shopping_item.dart';
import 'package:family_os/features/tasks/application/task_controller.dart';
import 'package:family_os/features/tasks/data/task_repository.dart';
import 'package:family_os/features/tasks/domain/family_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryFamilyRepository implements FamilyRepository {
  @override
  Future<String?> loadActiveFamilyId() async => 'family-1';

  @override
  Future<List<FamilyWorkspace>> loadFamilies() async {
    return <FamilyWorkspace>[
      const FamilyWorkspace(
        id: 'family-1',
        name: 'משפחת בדיקה',
        iconId: FamilyIcon.family,
        colorValue: 0xFF1256E8,
        inviteCode: 'ABC123',
        members: <FamilyMember>[
          FamilyMember(
            id: '1',
            name: 'יוסי',
            email: 'yossi@example.com',
            role: FamilyRole.admin,
          ),
          FamilyMember(
            id: '2',
            name: 'נועה',
            email: 'noa@example.com',
            role: FamilyRole.parent,
          ),
        ],
      ),
    ];
  }

  @override
  Future<void> saveActiveFamilyId(String? familyId) async {}

  @override
  Future<void> saveFamilies(
    List<FamilyWorkspace> families,
  ) async {}
}

class MemoryTaskRepository implements TaskRepository {
  @override
  Future<List<FamilyTask>> loadTasks() async => <FamilyTask>[];

  @override
  Future<void> saveTasks(List<FamilyTask> tasks) async {}
}

class MemoryShoppingRepository implements ShoppingRepository {
  @override
  Future<List<ShoppingItem>> loadItems() async => <ShoppingItem>[];

  @override
  Future<List<RecurringProduct>> loadRecurringProducts() async =>
      <RecurringProduct>[];

  @override
  Future<List<ProductCategoryPreference>> loadCategoryPreferences() async =>
      <ProductCategoryPreference>[];

  @override
  Future<void> saveItems(
    List<ShoppingItem> items,
  ) async {}

  @override
  Future<void> saveRecurringProducts(
    List<RecurringProduct> products,
  ) async {}

  @override
  Future<void> saveCategoryPreferences(
    List<ProductCategoryPreference> preferences,
  ) async {}
}

void main() {
  test(
    'dashboard summary reflects active family member count',
    () async {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          familyRepositoryProvider.overrideWithValue(
            MemoryFamilyRepository(),
          ),
          taskRepositoryProvider.overrideWithValue(
            MemoryTaskRepository(),
          ),
          shoppingRepositoryProvider.overrideWithValue(
            MemoryShoppingRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(familyControllerProvider.notifier).load();
      await container.read(taskControllerProvider.notifier).load();
      await container.read(shoppingControllerProvider.notifier).load();

      final summary = container.read(dashboardSummaryProvider);

      expect(summary.familyMembers, 2);
      expect(summary.openTasks, 0);
      expect(summary.overdueTasks, 0);
      expect(summary.shoppingItems, 0);
    },
  );
}
