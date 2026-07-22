import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/family_controller.dart';

class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final TextEditingController _code = TextEditingController(text: 'FAMILY');
  final TextEditingController _name = TextEditingController(text: 'יוסי');
  final TextEditingController _email =
      TextEditingController(text: 'demo@familyos.app');

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final family = await ref.read(familyControllerProvider.notifier).joinFamily(
          inviteCode: _code.text,
          memberName: _name.text,
          memberEmail: _email.text,
        );

    if (family != null && mounted) {
      context.go('/today');
    }
  }

  @override
  Widget build(BuildContext context) {
    final FamilyState state = ref.watch(familyControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('הצטרפות למשפחה')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: <Widget>[
            const AppCard(
              child: Column(
                children: <Widget>[
                  Icon(Icons.group_add_rounded, size: 54),
                  SizedBox(height: 12),
                  Text(
                    'יש לך קוד הזמנה?',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'הזן את הקוד שקיבלת ממנהל המשפחה.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: <Widget>[
                  AppTextField(
                    controller: _code,
                    label: 'קוד בן 6 תווים',
                    icon: Icons.key_rounded,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _name,
                    label: 'השם שלך',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _email,
                    label: 'כתובת המייל שלך',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
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
              label: 'הצטרף למשפחה',
              onPressed: _join,
              isLoading: state.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
