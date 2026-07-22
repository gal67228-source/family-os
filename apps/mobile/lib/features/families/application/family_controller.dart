import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/family_repository.dart';
import '../data/local_family_repository.dart';
import '../domain/family_icon.dart';
import '../domain/family_member.dart';
import '../domain/family_workspace.dart';

class FamilyState {
  const FamilyState({
    this.families = const <FamilyWorkspace>[],
    this.activeFamilyId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<FamilyWorkspace> families;
  final String? activeFamilyId;
  final bool isLoading;
  final String? errorMessage;

  FamilyWorkspace? get activeFamily {
    for (final FamilyWorkspace family in families) {
      if (family.id == activeFamilyId) {
        return family;
      }
    }
    return families.isEmpty ? null : families.first;
  }

  FamilyState copyWith({
    List<FamilyWorkspace>? families,
    String? activeFamilyId,
    bool clearActiveFamily = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FamilyState(
      families: families ?? this.families,
      activeFamilyId:
          clearActiveFamily ? null : activeFamilyId ?? this.activeFamilyId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class FamilyController extends StateNotifier<FamilyState> {
  FamilyController(this._repository) : super(const FamilyState()) {
    load();
  }

  final FamilyRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final List<FamilyWorkspace> families = await _repository.loadFamilies();
      final String? storedActiveId = await _repository.loadActiveFamilyId();
      final String? activeId = families.any(
        (FamilyWorkspace family) => family.id == storedActiveId,
      )
          ? storedActiveId
          : (families.isEmpty ? null : families.first.id);

      state = FamilyState(
        families: families,
        activeFamilyId: activeId,
      );

      await _repository.saveActiveFamilyId(activeId);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'לא הצלחנו לטעון את נתוני המשפחה.',
      );
    }
  }

  Future<FamilyWorkspace?> createFamily({
    required String name,
    required int iconId,
    required int colorValue,
    required String ownerName,
    required String ownerEmail,
  }) async {
    if (name.trim().length < 2) {
      state = state.copyWith(
        errorMessage: 'שם המשפחה קצר מדי.',
      );
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final String id = DateTime.now().microsecondsSinceEpoch.toString();
    final FamilyWorkspace family = FamilyWorkspace(
      id: id,
      name: name.trim(),
      iconId: iconId,
      colorValue: colorValue,
      inviteCode: _generateInviteCode(),
      members: <FamilyMember>[
        FamilyMember(
          id: 'member-$id',
          name: ownerName.trim().isEmpty ? 'מנהל המשפחה' : ownerName.trim(),
          email: ownerEmail.trim(),
          role: FamilyRole.admin,
        ),
      ],
    );

    final List<FamilyWorkspace> updated = <FamilyWorkspace>[
      ...state.families,
      family
    ];

    await _persist(updated, family.id);
    return family;
  }

  Future<FamilyWorkspace?> joinFamily({
    required String inviteCode,
    required String memberName,
    required String memberEmail,
  }) async {
    final String normalized = inviteCode.trim().toUpperCase();

    if (normalized.length != 6) {
      state = state.copyWith(
        errorMessage: 'קוד ההזמנה חייב להכיל 6 תווים.',
      );
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    FamilyWorkspace? matchingFamily;
    for (final FamilyWorkspace family in state.families) {
      if (family.inviteCode == normalized) {
        matchingFamily = family;
        break;
      }
    }

    if (matchingFamily == null) {
      final String id = DateTime.now().microsecondsSinceEpoch.toString();
      matchingFamily = FamilyWorkspace(
        id: id,
        name: 'המשפחה שלי',
        iconId: FamilyIcon.family,
        colorValue: const Color(0xFF1256E8).toARGB32(),
        inviteCode: normalized,
        members: <FamilyMember>[
          FamilyMember(
            id: 'member-$id',
            name: memberName.trim().isEmpty ? 'בן משפחה' : memberName.trim(),
            email: memberEmail.trim(),
            role: FamilyRole.parent,
          ),
        ],
      );

      final List<FamilyWorkspace> updated = <FamilyWorkspace>[
        ...state.families,
        matchingFamily
      ];
      await _persist(updated, matchingFamily.id);
      return matchingFamily;
    }

    final bool alreadyMember = matchingFamily.members.any(
      (FamilyMember member) =>
          member.email.toLowerCase() == memberEmail.trim().toLowerCase(),
    );

    final List<FamilyMember> members = alreadyMember
        ? matchingFamily.members
        : <FamilyMember>[
            ...matchingFamily.members,
            FamilyMember(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              name: memberName.trim().isEmpty ? 'בן משפחה' : memberName.trim(),
              email: memberEmail.trim(),
              role: FamilyRole.parent,
            ),
          ];

    final FamilyWorkspace updatedFamily =
        matchingFamily.copyWith(members: members);
    final List<FamilyWorkspace> updated = state.families
        .map(
          (FamilyWorkspace family) =>
              family.id == updatedFamily.id ? updatedFamily : family,
        )
        .toList();

    await _persist(updated, updatedFamily.id);
    return updatedFamily;
  }

  Future<void> selectFamily(String familyId) async {
    if (!state.families.any(
      (FamilyWorkspace family) => family.id == familyId,
    )) {
      return;
    }

    state = state.copyWith(
      activeFamilyId: familyId,
      clearError: true,
    );
    await _repository.saveActiveFamilyId(familyId);
  }

  Future<void> addMember({
    required String familyId,
    required String name,
    required String email,
    required FamilyRole role,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: 'יש להזין שם ומייל.',
      );
      return;
    }

    final List<FamilyWorkspace> updated = state.families.map(
      (FamilyWorkspace family) {
        if (family.id != familyId) {
          return family;
        }

        final FamilyMember member = FamilyMember(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name.trim(),
          email: email.trim(),
          role: role,
        );

        return family.copyWith(
          members: <FamilyMember>[...family.members, member],
        );
      },
    ).toList();

    await _persist(updated, state.activeFamilyId);
  }

  Future<void> removeMember({
    required String familyId,
    required String memberId,
  }) async {
    final List<FamilyWorkspace> updated = state.families.map(
      (FamilyWorkspace family) {
        if (family.id != familyId) {
          return family;
        }

        final List<FamilyMember> members = family.members
            .where((FamilyMember member) => member.id != memberId)
            .toList();

        return family.copyWith(members: members);
      },
    ).toList();

    await _persist(updated, state.activeFamilyId);
  }

  Future<void> leaveFamily(String familyId) async {
    final List<FamilyWorkspace> updated = state.families
        .where((FamilyWorkspace family) => family.id != familyId)
        .toList();

    final String? nextActiveId = state.activeFamilyId == familyId
        ? (updated.isEmpty ? null : updated.first.id)
        : state.activeFamilyId;

    await _persist(updated, nextActiveId);
  }

  Future<void> clear() async {
    await _persist(<FamilyWorkspace>[], null);
  }

  Future<void> _persist(
    List<FamilyWorkspace> families,
    String? activeFamilyId,
  ) async {
    await _repository.saveFamilies(families);
    await _repository.saveActiveFamilyId(activeFamilyId);
    state = FamilyState(
      families: families,
      activeFamilyId: activeFamilyId,
    );
  }

  String _generateInviteCode() {
    const String alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final Random random = Random();
    return List<String>.generate(
      6,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }
}

final Provider<FamilyRepository> familyRepositoryProvider =
    Provider<FamilyRepository>(
  (Ref ref) => LocalFamilyRepository(),
);

final StateNotifierProvider<FamilyController, FamilyState>
    familyControllerProvider =
    StateNotifierProvider<FamilyController, FamilyState>(
  (Ref ref) => FamilyController(
    ref.watch(familyRepositoryProvider),
  ),
);
