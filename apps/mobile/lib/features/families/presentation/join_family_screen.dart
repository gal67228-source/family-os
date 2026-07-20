import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/app_user.dart';
import '../application/family_controller.dart';

class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final TextEditingController _code =
      TextEditingController(text: 'FAMILY1');
  UserRole _role = UserRole.member;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final family = await ref.read(familyControllerProvider.notifier).joinFamily(
          invitationCode: _code.text,
          role: _role,
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
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'קוד הזמנה',
                prefixIcon: Icon(Icons.key_rounded),
              ),
            ),
            const SizedBox(height: 18),
            SegmentedButton<UserRole>(
              segments: const <ButtonSegment<UserRole>>[
                ButtonSegment<UserRole>(
                  value: UserRole.member,
                  label: Text('משתמש רגיל'),
                  icon: Icon(Icons.person_outline_rounded),
                ),
                ButtonSegment<UserRole>(
                  value: UserRole.admin,
                  label: Text('Admin'),
                  icon: Icon(Icons.admin_panel_settings_outlined),
                ),
              ],
              selected: <UserRole>{_role},
              onSelectionChanged: (Set<UserRole> value) {
                setState(() {
                  _role = value.first;
                });
              },
            ),
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: state.isLoading ? null : _join,
              child: const Text('הצטרף למשפחה'),
            ),
          ],
        ),
      ),
    );
  }
}
