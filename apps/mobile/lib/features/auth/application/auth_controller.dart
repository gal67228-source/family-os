import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_user.dart';

enum AuthStatus {
  signedOut,
  signedIn,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  const AuthState.signedOut()
      : status = AuthStatus.signedOut,
        user = null,
        isLoading = false,
        errorMessage = null;

  final AuthStatus status;
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState.signedOut());

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!_isValidEmail(email)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'כתובת המייל אינה תקינה.',
      );
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'הסיסמה חייבת להכיל לפחות 6 תווים.',
      );
      return false;
    }

    state = AuthState(
      status: AuthStatus.signedIn,
      user: AppUser(
        id: 'demo-user',
        email: email.trim(),
        displayName: _displayNameFromEmail(email),
      ),
    );
    return true;
  }

  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (displayName.trim().length < 2) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'יש להזין שם באורך שני תווים לפחות.',
      );
      return false;
    }

    if (!_isValidEmail(email)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'כתובת המייל אינה תקינה.',
      );
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'הסיסמה חייבת להכיל לפחות 6 תווים.',
      );
      return false;
    }

    state = AuthState(
      status: AuthStatus.signedIn,
      user: AppUser(
        id: 'demo-user',
        email: email.trim(),
        displayName: displayName.trim(),
      ),
    );
    return true;
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!_isValidEmail(email)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'כתובת המייל אינה תקינה.',
      );
      return false;
    }

    state = state.copyWith(isLoading: false, clearError: true);
    return true;
  }

  void signOut() {
    state = const AuthState.signedOut();
  }

  bool _isValidEmail(String value) {
    final String email = value.trim();
    return email.contains('@') && email.contains('.');
  }

  String _displayNameFromEmail(String email) {
    final String localPart = email.trim().split('@').first;
    if (localPart.isEmpty) {
      return 'משתמש';
    }
    return localPart[0].toUpperCase() + localPart.substring(1);
  }
}

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (Ref ref) => AuthController(),
);
