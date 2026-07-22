import 'package:family_os/features/families/application/family_controller.dart';
import 'package:family_os/features/families/data/family_repository.dart';
import 'package:family_os/features/families/domain/family_icon.dart';
import 'package:family_os/features/families/domain/family_workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryFamilyRepository implements FamilyRepository {
  List<FamilyWorkspace> families = <FamilyWorkspace>[];
  String? activeFamilyId;

  @override
  Future<String?> loadActiveFamilyId() async => activeFamilyId;

  @override
  Future<List<FamilyWorkspace>> loadFamilies() async => families;

  @override
  Future<void> saveActiveFamilyId(String? familyId) async {
    activeFamilyId = familyId;
  }

  @override
  Future<void> saveFamilies(List<FamilyWorkspace> value) async {
    families = value;
  }
}

void main() {
  test('creates and selects a family', () async {
    final MemoryFamilyRepository repository = MemoryFamilyRepository();
    final FamilyController controller = FamilyController(repository);

    await controller.load();

    final FamilyWorkspace? family = await controller.createFamily(
      name: 'משפחת בדיקה',
      iconId: FamilyIcon.family,
      colorValue: const Color(0xFF1256E8).toARGB32(),
      ownerName: 'יוסי',
      ownerEmail: 'demo@familyos.app',
    );

    expect(family, isNotNull);
    expect(controller.state.families, hasLength(1));
    expect(controller.state.activeFamilyId, family!.id);
    expect(controller.state.activeFamily?.members, hasLength(1));
  });

  test('switches active family', () async {
    final MemoryFamilyRepository repository = MemoryFamilyRepository();
    final FamilyController controller = FamilyController(repository);

    await controller.load();

    final FamilyWorkspace first = (await controller.createFamily(
      name: 'ראשונה',
      iconId: FamilyIcon.family,
      colorValue: const Color(0xFF1256E8).toARGB32(),
      ownerName: 'א',
      ownerEmail: 'a@example.com',
    ))!;

    final FamilyWorkspace second = (await controller.createFamily(
      name: 'שנייה',
      iconId: FamilyIcon.family,
      colorValue: const Color(0xFF22C55E).toARGB32(),
      ownerName: 'ב',
      ownerEmail: 'b@example.com',
    ))!;

    await controller.selectFamily(first.id);
    expect(controller.state.activeFamilyId, first.id);

    await controller.selectFamily(second.id);
    expect(controller.state.activeFamilyId, second.id);
  });
}
