import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/family_workspace.dart';
import 'family_repository.dart';

class LocalFamilyRepository implements FamilyRepository {
  static const String _familiesKey = 'family_os_families';
  static const String _activeFamilyKey = 'family_os_active_family_id';

  @override
  Future<List<FamilyWorkspace>> loadFamilies() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_familiesKey);

    if (raw == null || raw.isEmpty) {
      return <FamilyWorkspace>[];
    }

    final Object? decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) {
      return <FamilyWorkspace>[];
    }

    return decoded
        .whereType<Map<String, Object?>>()
        .map(FamilyWorkspace.fromJson)
        .toList();
  }

  @override
  Future<void> saveFamilies(List<FamilyWorkspace> families) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String raw = jsonEncode(
      families.map((FamilyWorkspace family) => family.toJson()).toList(),
    );
    await preferences.setString(_familiesKey, raw);
  }

  @override
  Future<String?> loadActiveFamilyId() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_activeFamilyKey);
  }

  @override
  Future<void> saveActiveFamilyId(String? familyId) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    if (familyId == null) {
      await preferences.remove(_activeFamilyKey);
      return;
    }

    await preferences.setString(_activeFamilyKey, familyId);
  }
}
