import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';

class FamilySetupScreen extends StatelessWidget {
  const FamilySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('המשפחה שלי')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: <Widget>[
            Text(
              'איך תרצה להתחיל?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'צור משפחה חדשה או הצטרף למשפחה קיימת.',
            ),
            const SizedBox(height: 22),
            AppCard(
              onTap: () => context.push('/family/create'),
              child: const _SetupOption(
                icon: Icons.add_home_work_rounded,
                title: 'יצירת משפחה',
                subtitle: 'צור מרחב חדש והזמן את בני המשפחה.',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              onTap: () => context.push('/family/join'),
              child: const _SetupOption(
                icon: Icons.group_add_rounded,
                title: 'הצטרפות למשפחה',
                subtitle: 'השתמש בקוד הזמנה בן 6 תווים.',
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupOption extends StatelessWidget {
  const _SetupOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
        const Icon(Icons.chevron_left_rounded),
      ],
    );
  }
}
