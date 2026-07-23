import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../../families/application/family_controller.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('עוד')),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded),
              title: const Text('החלפת משפחה'),
              onTap: () => context.push('/family/switch'),
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts_rounded),
              title: const Text('ניהול המשפחה'),
              onTap: () => context.push('/family/manage'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_rounded),
              title: const Text('יומן משפחתי'),
              onTap: () => context.push('/calendar'),
            ),
            const ListTile(
              leading: Icon(Icons.timeline_rounded),
              title: Text('Timeline'),
            ),
            const ListTile(
              leading: Icon(Icons.description_rounded),
              title: Text('מסמכים'),
            ),
            const ListTile(
              leading: Icon(Icons.settings_rounded),
              title: Text('הגדרות'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('יציאה מהחשבון'),
              onTap: () {
                ref.read(authControllerProvider.notifier).signOut();
                ref.read(familyControllerProvider.notifier).clear();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
