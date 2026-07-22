import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/family_controller.dart';
import '../domain/family_icon.dart';
import '../domain/family_workspace.dart';

class SwitchFamilyScreen extends ConsumerWidget {
  const SwitchFamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FamilyState state = ref.watch(familyControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('החלפת משפחה')),
        body: state.isLoading
            ? const LoadingView(message: 'טוען משפחות...')
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: <Widget>[
                  if (state.families.isEmpty)
                    EmptyState(
                      icon: Icons.family_restroom_rounded,
                      title: 'עדיין אין משפחה',
                      message: 'צור משפחה חדשה או הצטרף באמצעות קוד הזמנה.',
                      action: FilledButton(
                        onPressed: () => context.push('/family/setup'),
                        child: const Text('התחל עכשיו'),
                      ),
                    ),
                  for (final FamilyWorkspace family in state.families)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () async {
                          await ref
                              .read(familyControllerProvider.notifier)
                              .selectFamily(family.id);
                          if (context.mounted) {
                            context.pop();
                          }
                        },
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(family.colorValue),
                              child: Icon(
                                FamilyIcon.fromId(family.iconId),
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    family.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${family.members.length} חברים',
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              state.activeFamilyId == family.id
                                  ? Icons.check_circle_rounded
                                  : Icons.chevron_left_rounded,
                              color: state.activeFamilyId == family.id
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
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
