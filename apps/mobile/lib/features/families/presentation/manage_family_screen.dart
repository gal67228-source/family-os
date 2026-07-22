import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../application/family_controller.dart';
import '../domain/family_icon.dart';
import '../domain/family_member.dart';
import '../domain/family_workspace.dart';

class ManageFamilyScreen extends ConsumerStatefulWidget {
  const ManageFamilyScreen({super.key});

  @override
  ConsumerState<ManageFamilyScreen> createState() => _ManageFamilyScreenState();
}

class _ManageFamilyScreenState extends ConsumerState<ManageFamilyScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  FamilyRole _role = FamilyRole.parent;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _openAddMember(FamilyWorkspace family) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  MediaQuery.viewInsetsOf(context).bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'הוספת בן משפחה',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _name,
                      label: 'שם',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _email,
                      label: 'מייל',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<FamilyRole>(
                      initialValue: _role,
                      decoration: const InputDecoration(labelText: 'תפקיד'),
                      items: FamilyRole.values
                          .map(
                            (FamilyRole role) => DropdownMenuItem<FamilyRole>(
                              value: role,
                              child: Text(role.label),
                            ),
                          )
                          .toList(),
                      onChanged: (FamilyRole? value) {
                        if (value == null) {
                          return;
                        }
                        setModalState(() {
                          _role = value;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    AppPrimaryButton(
                      label: 'הוסף חבר',
                      onPressed: () async {
                        await ref
                            .read(familyControllerProvider.notifier)
                            .addMember(
                              familyId: family.id,
                              name: _name.text,
                              email: _email.text,
                              role: _role,
                            );
                        _name.clear();
                        _email.clear();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FamilyState state = ref.watch(familyControllerProvider);
    final FamilyWorkspace? family = state.activeFamily;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ניהול המשפחה')),
        body: family == null
            ? EmptyState(
                icon: Icons.family_restroom_rounded,
                title: 'אין משפחה פעילה',
                message: 'צור משפחה או הצטרף למשפחה קיימת.',
                action: FilledButton(
                  onPressed: () => context.go('/family/setup'),
                  child: const Text('התחל'),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: <Widget>[
                  AppCard(
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Color(family.colorValue),
                          child: Icon(
                            FamilyIcon.fromId(family.iconId),
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          family.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'קוד הזמנה: ${family.inviteCode}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'חברי המשפחה',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () => _openAddMember(family),
                        icon: const Icon(Icons.person_add_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final FamilyMember member in family.members)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              child: Text(
                                member.name.isEmpty
                                    ? '?'
                                    : member.name.characters.first,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    member.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${member.email} · ${member.role.label}',
                                  ),
                                ],
                              ),
                            ),
                            if (member.role != FamilyRole.admin)
                              IconButton(
                                onPressed: () => ref
                                    .read(
                                      familyControllerProvider.notifier,
                                    )
                                    .removeMember(
                                      familyId: family.id,
                                      memberId: member.id,
                                    ),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  AppSecondaryButton(
                    label: 'עזיבת המשפחה',
                    icon: Icons.logout_rounded,
                    onPressed: () async {
                      await ref
                          .read(familyControllerProvider.notifier)
                          .leaveFamily(family.id);
                      if (context.mounted) {
                        context.go('/family/setup');
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
