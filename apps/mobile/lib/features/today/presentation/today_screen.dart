import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../dashboard/application/dashboard_provider.dart';
import '../../dashboard/domain/dashboard_summary.dart';
import '../../dashboard/presentation/dashboard_stat_card.dart';
import '../../families/application/family_controller.dart';
import '../../families/domain/family_workspace.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FamilyState familyState = ref.watch(familyControllerProvider);
    final DashboardSummary summary = ref.watch(dashboardSummaryProvider);
    final FamilyWorkspace? family = familyState.activeFamily;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            family?.name ?? 'Family OS',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: <Widget>[
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
                            onTap: () => context.go('/tasks'),
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
                            onTap: () => context.go('/shopping'),
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
                                'יצירת משימות תופעל בצעד הבא',
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
