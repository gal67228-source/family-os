import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/app_user.dart';
import '../domain/family_workspace.dart';

class FamilyState {
  const FamilyState({
    this.families = const <FamilyWorkspace>[],
    this.selectedFamilyId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<FamilyWorkspace> families;
  final String? selectedFamilyId;
  final bool isLoading;
  final String? errorMessage;

  FamilyWorkspace? get selectedFamily {
    if (selectedFamilyId == null) {
      return null;
    }
    for (final FamilyWorkspace family in families) {
      if (family.id == selectedFamilyId) {
        return family;
      }
    }
    return null;
  }

  FamilyState copyWith({
    List<FamilyWorkspace>? families,
    String? selectedFamilyId,
    bool clearSelectedFamily = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FamilyState(
      families: families ?? this.families,
      selectedFamilyId: clearSelectedFamily
          ? null
          : selectedFamilyId ?? this.selectedFamilyId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class FamilyController extends StateNotifier<FamilyState> {
  FamilyController() : super(const FamilyState());

  Future<FamilyWorkspace?> createFamily({
    required String name,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (name.trim().length < 2) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'שם המשפחה קצר מדי.',
      );
      return null;
    }

    final FamilyWorkspace family = FamilyWorkspace(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      role: role,
    );

    state = FamilyState(
      families: <FamilyWorkspace>[...state.families, family],
      selectedFamilyId: family.id,
    );
    return family;
  }

  Future<FamilyWorkspace?> joinFamily({
    required String invitationCode,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (invitationCode.trim().length < 6) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'קוד ההזמנה חייב להכיל לפחות 6 תווים.',
      );
      return null;
    }

    final FamilyWorkspace family = FamilyWorkspace(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: 'המשפחה שלי',
      role: role,
    );

    state = FamilyState(
      families: <FamilyWorkspace>[...state.families, family],
      selectedFamilyId: family.id,
    );
    return family;
  }

  void selectFamily(String familyId) {
    state = state.copyWith(selectedFamilyId: familyId, clearError: true);
  }

  void clear() {
    state = const FamilyState();
  }
}

final StateNotifierProvider<FamilyController, FamilyState>
    familyControllerProvider =
    StateNotifierProvider<FamilyController, FamilyState>(
  (Ref ref) => FamilyController(),
);
