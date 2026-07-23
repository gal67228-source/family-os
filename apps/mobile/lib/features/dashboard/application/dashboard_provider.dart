import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../families/application/family_controller.dart';
import '../../shopping/application/shopping_controller.dart';
import '../../shopping/domain/shopping_item.dart';
import '../../tasks/application/task_controller.dart';
import '../../tasks/domain/family_task.dart';
import '../domain/dashboard_summary.dart';

final Provider<DashboardSummary> dashboardSummaryProvider =
    Provider<DashboardSummary>((Ref ref) {
  final FamilyState familyState = ref.watch(familyControllerProvider);
  final List<FamilyTask> tasks = ref.watch(activeFamilyTasksProvider);
  final List<ShoppingItem> shopping =
      ref.watch(allActiveFamilyShoppingItemsProvider);

  return DashboardSummary(
    openTasks: tasks.where((FamilyTask task) => !task.isCompleted).length,
    overdueTasks: tasks.where((FamilyTask task) => task.isOverdue).length,
    shoppingItems:
        shopping.where((ShoppingItem item) => !item.isChecked).length,
    familyMembers: familyState.activeFamily?.members.length ?? 0,
  );
});
