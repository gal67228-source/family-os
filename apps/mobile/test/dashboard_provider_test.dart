import 'package:family_os/features/dashboard/application/dashboard_provider.dart';
import 'package:family_os/features/families/application/family_controller.dart';
import 'package:family_os/features/families/data/family_repository.dart';
import 'package:family_os/features/families/domain/family_icon.dart';
import 'package:family_os/features/families/domain/family_member.dart';
import 'package:family_os/features/families/domain/family_workspace.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryFamilyRepository implements FamilyRepository {
  @override
  Future<String?> loadActiveFamilyId() async => 'family-1';

  @override
  Future<List<FamilyWorkspace>> loadFamilies() async {
    return <FamilyWorkspace>[
      const FamilyWorkspace(
        id: 'family-1',
        name: 'משפחת בדיקה',
        iconId: FamilyIcon.family,
        colorValue: 0xFF1256E8,
        inviteCode: 'ABC123',
        members: <FamilyMember>[
          FamilyMember(
            id: '1',
            name: 'יוסי',
            email: 'yossi@example.com',
            role: FamilyRole.admin,
          ),
          FamilyMember(
            id: '2',
            name: 'נועה',
            email: 'noa@example.com',
            role: FamilyRole.parent,
          ),
        ],
      ),
    ];
  }

  @override
  Future<void> saveActiveFamilyId(String? familyId) async {}

  @override
  Future<void> saveFamilies(List<FamilyWorkspace> families) async {}
}

void main() {
  test('dashboard summary reflects active family member count', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        familyRepositoryProvider.overrideWithValue(
          _MemoryFamilyRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(familyControllerProvider.notifier).load();

    final summary = container.read(dashboardSummaryProvider);
    expect(summary.familyMembers, 2);
    expect(summary.openTasks, 0);
    expect(summary.shoppingItems, 0);
  });
}
