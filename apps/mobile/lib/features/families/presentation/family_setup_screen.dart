import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FamilySetupScreen extends StatelessWidget {
  const FamilySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('המשפחה שלי')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Text(
              'איך תרצה להתחיל?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'אפשר ליצור משפחה חדשה או להצטרף למשפחה קיימת באמצעות קוד הזמנה.',
            ),
            const SizedBox(height: 24),
            _SetupCard(
              icon: Icons.add_home_work_rounded,
              title: 'יצירת משפחה',
              subtitle: 'אתה תהיה מנהל המשפחה הראשון.',
              actionText: 'צור משפחה',
              onTap: () => context.push('/family/create'),
            ),
            const SizedBox(height: 14),
            _SetupCard(
              icon: Icons.group_add_rounded,
              title: 'הצטרפות למשפחה',
              subtitle: 'הזן קוד הזמנה שקיבלת ממנהל המשפחה.',
              actionText: 'הצטרף',
              onTap: () => context.push('/family/join'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              size: 46,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onTap,
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}
