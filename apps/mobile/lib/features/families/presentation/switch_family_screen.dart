import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/family_controller.dart';
import '../domain/family.dart';

class SwitchFamilyScreen extends ConsumerWidget {
  const SwitchFamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FamilyState state = ref.watch(familyControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('החלפת משפחה')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            if (state.families.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('עדיין לא קיימות משפחות בחשבון.'),
                ),
              ),
            for (final Family family in state.families)
              Card(
                child: RadioListTile<String>(
                  value: family.id,
                  groupValue: state.selectedFamilyId,
                  title: Text(family.name),
                  subtitle: Text(
                    family.role.name == 'admin' ? 'Admin' : 'משתמש רגיל',
                  ),
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }
                    ref.read(familyControllerProvider.notifier).selectFamily(value);
                    context.pop();
                  },
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/family/setup'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('הוסף משפחה'),
            ),
          ],
        ),
      ),
    );
  }
}
