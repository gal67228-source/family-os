import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/family_os_logo.dart';
import '../../dashboard/application/dashboard_provider.dart';
import '../../dashboard/domain/dashboard_summary.dart';
import '../../dashboard/presentation/dashboard_stat_card.dart';
import '../../families/application/family_controller.dart';
import '../../families/domain/family_workspace.dart';
import '../../tasks/application/task_controller.dart';
import '../../tasks/domain/family_task.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  Future<void> _openQuickAdd(BuildContext context) async {
    final String? route = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'מה מוסיפים למשפחה?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _QuickAddTile(
                          icon: Icons.add_task_rounded,
                          label: 'משימה',
                          color: AppColors.primary,
                          onTap: () => Navigator.pop(
                            sheetContext,
                            '/tasks/new',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAddTile(
                          icon: Icons.event_rounded,
                          label: 'אירוע',
                          color: const Color(0xFF7C3AED),
                          onTap: () => Navigator.pop(
                            sheetContext,
                            '/calendar/new',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAddTile(
                          icon: Icons.add_shopping_cart_rounded,
                          label: 'מוצר',
                          color: AppColors.secondary,
                          onTap: () => Navigator.pop(
                            sheetContext,
                            '/shopping/add',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (route != null && context.mounted) {
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FamilyState familyState = ref.watch(familyControllerProvider);
    final DashboardSummary summary = ref.watch(dashboardSummaryProvider);
    final FamilyWorkspace? family = familyState.activeFamily;
    final List<FamilyTask> upcomingTasks = ref
        .watch(activeFamilyTasksProvider)
        .where((FamilyTask task) => !task.isCompleted)
        .take(3)
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const FamilyOsLogo(size: 36),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  family?.name ?? 'Family OS',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'הוספה מהירה',
              onPressed: () => _openQuickAdd(context),
              icon: const Icon(
                Icons.add_circle_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            IconButton(
              tooltip: 'החלפת משפחה',
              onPressed: () => context.push('/family/switch'),
              icon: const Icon(Icons.swap_horiz_rounded),
            ),
            IconButton(
              tooltip: 'התראות',
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        body: familyState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : family == null
                ? EmptyState(
                    icon: Icons.family_restroom_rounded,
                    title: 'עדיין אין משפחה פעילה',
                    message: 'צור משפחה חדשה או הצטרף למשפחה קיימת כדי להתחיל.',
                    action: FilledButton(
                      onPressed: () => context.go('/family/setup'),
                      child: const Text('הגדרת משפחה'),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 112),
                    children: <Widget>[
                      Text(
                        'בוקר טוב 👋',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'הנה תמונת המצב של ${family.name}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: <Widget>[
                          DashboardStatCard(
                            icon: Icons.task_alt_rounded,
                            title: 'משימות פתוחות',
                            value: '${summary.openTasks}',
                            background: AppColors.softBlue,
                            foreground: AppColors.primary,
                            onTap: () => context.push('/tasks/new'),
                          ),
                          DashboardStatCard(
                            icon: Icons.warning_amber_rounded,
                            title: 'משימות באיחור',
                            value: '${summary.overdueTasks}',
                            background: const Color(0xFFFFECEC),
                            foreground: AppColors.error,
                            onTap: () => context.go('/tasks'),
                          ),
                          DashboardStatCard(
                            icon: Icons.shopping_cart_rounded,
                            title: 'פריטים לקנייה',
                            value: '${summary.shoppingItems}',
                            background: AppColors.softGreen,
                            foreground: AppColors.secondary,
                            onTap: () => context.push('/shopping/add'),
                          ),
                          DashboardStatCard(
                            icon: Icons.group_rounded,
                            title: 'בני משפחה',
                            value: '${summary.familyMembers}',
                            background: AppColors.softPurple,
                            foreground: const Color(0xFF8B5CF6),
                            onTap: () => context.push('/family/manage'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'משימות קרובות',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/tasks'),
                            child: const Text('הצג הכול'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (upcomingTasks.isEmpty)
                        const AppCard(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.task_alt_rounded,
                                color: AppColors.secondary,
                              ),
                              SizedBox(width: 10),
                              Text('אין משימות פתוחות'),
                            ],
                          ),
                        )
                      else
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: <Widget>[
                              for (int index = 0;
                                  index < upcomingTasks.length;
                                  index++) ...<Widget>[
                                ListTile(
                                  leading: IconButton(
                                    tooltip: 'סמן כהושלם',
                                    onPressed: () => ref
                                        .read(
                                          taskControllerProvider.notifier,
                                        )
                                        .toggleCompleted(
                                          upcomingTasks[index].id,
                                        ),
                                    icon: Icon(
                                      Icons.circle_outlined,
                                      color: upcomingTasks[index].isOverdue
                                          ? AppColors.error
                                          : AppColors.primary,
                                    ),
                                  ),
                                  title: Text(
                                    upcomingTasks[index].title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${upcomingTasks[index].dueDate.day}/'
                                    '${upcomingTasks[index].dueDate.month}'
                                    '${upcomingTasks[index].assigneeName.isEmpty ? '' : ' · ${upcomingTasks[index].assigneeName}'}',
                                    style: TextStyle(
                                      color: upcomingTasks[index].isOverdue
                                          ? AppColors.error
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_left_rounded,
                                  ),
                                  onTap: () => context.push('/tasks/new'),
                                ),
                                if (index < upcomingTasks.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 22),
                      Text(
                        'פעולות מהירות',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.softBlue,
                                child: Icon(
                                  Icons.add_task_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: const Text('הוסף משימה'),
                              subtitle: const Text(
                                'צור משימה חדשה למשפחה',
                              ),
                              trailing: const Icon(Icons.chevron_left_rounded),
                              onTap: () => context.go('/tasks'),
                            ),
                            ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.softOrange,
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: AppColors.accent,
                                ),
                              ),
                              title: const Text('פתח יומן משפחתי'),
                              subtitle: const Text(
                                'אירועים, תורים וחופשות במקום אחד',
                              ),
                              trailing: const Icon(Icons.chevron_left_rounded),
                              onTap: () => context.push('/calendar'),
                            ),
                            const Divider(height: 1),
                            const Divider(height: 1),
                            ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.softGreen,
                                child: Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: AppColors.secondary,
                                ),
                              ),
                              title: const Text('הוסף מוצר לקניות'),
                              subtitle: const Text(
                                'ניהול רשימות יופעל בצעד הבא',
                              ),
                              trailing: const Icon(Icons.chevron_left_rounded),
                              onTap: () => context.go('/shopping'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.softPurple,
                                child: Icon(
                                  Icons.manage_accounts_rounded,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                              title: const Text('ניהול המשפחה'),
                              subtitle: Text(
                                '${family.members.length} חברים במשפחה',
                              ),
                              trailing: const Icon(Icons.chevron_left_rounded),
                              onTap: () => context.push('/family/manage'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Icon(icon),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
