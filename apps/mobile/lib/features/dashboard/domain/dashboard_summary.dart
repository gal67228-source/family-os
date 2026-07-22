class DashboardSummary {
  const DashboardSummary({
    required this.openTasks,
    required this.overdueTasks,
    required this.shoppingItems,
    required this.familyMembers,
  });

  final int openTasks;
  final int overdueTasks;
  final int shoppingItems;
  final int familyMembers;
}
