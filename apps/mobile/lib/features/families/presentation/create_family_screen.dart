import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/app_user.dart';
import '../application/family_controller.dart';

class CreateFamilyScreen extends ConsumerStatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  ConsumerState<CreateFamilyScreen> createState() =>
      _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends ConsumerState<CreateFamilyScreen> {
  final TextEditingController _name =
      TextEditingController(text: 'משפחת כהן');

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final family = await ref.read(familyControllerProvider.notifier).createFamily(
          name: _name.text,
          role: UserRole.admin,
        );

    if (family != null && mounted) {
      context.go('/family/invite');
    }
  }

  @override
  Widget build(BuildContext context) {
    final FamilyState state = ref.watch(familyControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('יצירת משפחה')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            const Icon(Icons.home_work_rounded, size: 64),
            const SizedBox(height: 18),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'שם המשפחה',
                prefixIcon: Icon(Icons.family_restroom_rounded),
              ),
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
              onPressed: state.isLoading ? null : _create,
              child: const Text('צור משפחה'),
            ),
          ],
        ),
      ),
    );
  }
}
