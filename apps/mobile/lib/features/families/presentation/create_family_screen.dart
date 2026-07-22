import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/family_controller.dart';
import '../domain/family_icon.dart';

class CreateFamilyScreen extends ConsumerStatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  ConsumerState<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends ConsumerState<CreateFamilyScreen> {
  final TextEditingController _name = TextEditingController(text: 'משפחת כהן');
  final TextEditingController _ownerName = TextEditingController(text: 'יוסי');
  final TextEditingController _ownerEmail =
      TextEditingController(text: 'demo@familyos.app');

  int _selectedIcon = FamilyIcon.family;
  int _selectedColor = AppColors.primary.toARGB32();

  @override
  void dispose() {
    _name.dispose();
    _ownerName.dispose();
    _ownerEmail.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final family =
        await ref.read(familyControllerProvider.notifier).createFamily(
              name: _name.text,
              iconId: _selectedIcon,
              colorValue: _selectedColor,
              ownerName: _ownerName.text,
              ownerEmail: _ownerEmail.text,
            );

    if (family != null && mounted) {
      context.go('/today');
    }
  }

  @override
  Widget build(BuildContext context) {
    final FamilyState state = ref.watch(familyControllerProvider);
    final List<({int id, IconData icon})> icons = <({int id, IconData icon})>[
      (id: FamilyIcon.family, icon: Icons.family_restroom_rounded),
      (id: FamilyIcon.home, icon: Icons.home_rounded),
      (id: FamilyIcon.favorite, icon: Icons.favorite_rounded),
      (id: FamilyIcon.pets, icon: Icons.pets_rounded),
    ];
    final List<Color> colors = <Color>[
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      const Color(0xFF8B5CF6),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('יצירת משפחה')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: <Widget>[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppTextField(
                    controller: _name,
                    label: 'שם המשפחה',
                    icon: Icons.edit_rounded,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _ownerName,
                    label: 'השם שלך',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _ownerEmail,
                    label: 'כתובת המייל שלך',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'בחר אייקון',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: icons.map((({int id, IconData icon}) item) {
                      final bool selected = item.id == _selectedIcon;
                      return ChoiceChip(
                        label: Icon(
                          item.icon,
                          color:
                              selected ? Colors.white : AppColors.textPrimary,
                        ),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        onSelected: (_) {
                          setState(() {
                            _selectedIcon = item.id;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'בחר צבע',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children: colors.map((Color color) {
                      final bool selected = color.toARGB32() == _selectedColor;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedColor = color.toARGB32();
                          });
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: CircleAvatar(
                          radius: 19,
                          backgroundColor: color,
                          child: selected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 18),
            AppPrimaryButton(
              label: 'צור משפחה',
              onPressed: _create,
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
