import '../domain/family_workspace.dart';

abstract interface class FamilyRepository {
  Future<List<FamilyWorkspace>> loadFamilies();
  Future<void> saveFamilies(List<FamilyWorkspace> families);
  Future<String?> loadActiveFamilyId();
  Future<void> saveActiveFamilyId(String? familyId);
}
