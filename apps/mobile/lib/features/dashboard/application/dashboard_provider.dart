import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../families/application/family_controller.dart';
import '../domain/dashboard_summary.dart';

final Provider<DashboardSummary> dashboardSummaryProvider =
    Provider<DashboardSummary>((Ref ref) {
  final FamilyState familyState = ref.watch(familyControllerProvider);
  final int memberCount = familyState.activeFamily?.members.length ?? 0;

  return DashboardSummary(
    openTasks: 0,
    overdueTasks: 0,
    shoppingItems: 0,
    familyMembers: memberCount,
  );
});
