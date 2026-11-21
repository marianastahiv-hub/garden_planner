import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/auth_repository.dart';
import '../../../data/telemetry_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Coordinates account operations and emits provider-independent UI states.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, this._telemetry) : super(const AuthState()) {
    on<AuthStatusChanged>((event, emit) {
      emit(
        state.copyWith(
          status: event.user == null
              ? AuthStatus.signedOut
              : AuthStatus.signedIn,
          user: event.user,
          clearUser: event.user == null,
        ),
      );
    });
    on<AuthSignInSubmitted>(_signIn);
    on<AuthSignUpSubmitted>(_signUp);
    on<AuthPasswordResetRequested>(_resetPassword);
    on<AuthSignOutRequested>(_signOut);
    on<AuthDisplayNameChanged>(_updateName);
    on<AuthPhotoChanged>(_updatePhoto);
    on<AuthPasswordChanged>(_changePassword);

    _sessionSubscription = _repository.authStateChanges.listen(
      (user) => add(AuthStatusChanged(user)),
      onError: (Object error) =>
          add(AuthStatusChanged(_repository.currentUser)),
    );
  }

  final AuthRepository _repository;
  final TelemetryRepository _telemetry;
  late final StreamSubscription<AuthUser?> _sessionSubscription;

  Future<void> _signIn(
    AuthSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.submitting, clearMessage: true));
    try {
      final user = await _repository.signIn(
        email: event.email,
        password: event.password,
      );
      unawaited(_logAuthEvent('login'));
      emit(state.copyWith(status: AuthStatus.signedIn, user: user));
    } catch (error) {
      _emitError(emit, error, AuthStatus.signedOut);
    }
  }

  Future<void> _signUp(
    AuthSignUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.submitting, clearMessage: true));
    try {
      final user = await _repository.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      unawaited(_logAuthEvent('sign_up'));
      emit(state.copyWith(status: AuthStatus.signedIn, user: user));
    } catch (error) {
      _emitError(emit, error, AuthStatus.signedOut);
    }
  }

  Future<void> _resetPassword(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.submitting, clearMessage: true));
    try {
      await _repository.sendPasswordResetEmail(email: event.email);
      emit(
        state.copyWith(
          status: AuthStatus.signedOut,
          message: 'Password reset email sent.',
          messageIsError: false,
          revision: state.revision + 1,
        ),
      );
    } catch (error) {
      _emitError(emit, error, AuthStatus.signedOut);
    }
  }

  Future<void> _signOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.submitting, clearMessage: true));
    try {
      await _repository.signOut();
      emit(state.copyWith(status: AuthStatus.signedOut, clearUser: true));
    } catch (error) {
      _emitError(emit, error, AuthStatus.signedIn);
    }
  }

  Future<void> _updateName(
    AuthDisplayNameChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.submitting, clearMessage: true));
    try {
      await _repository.updateDisplayName(event.name);
      final user = _repository.currentUser;
      emit(
        state.copyWith(
          status: AuthStatus.signedIn,
          user: user,
          message: 'Name updated.',
          messageIsError: false,
          revision: state.revision + 1,
        ),
      );
    } catch (error) {
      _emitError(emit, error, AuthStatus.signedIn);
    }
  }

  Future<void> _updatePhoto(
    AuthPhotoChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.submitting, clearMessage: true));
    try {
      await _repository.updatePhotoUrl(event.photoUrl);
      emit(
        state.copyWith(
          status: AuthStatus.signedIn,
          user: _repository.currentUser,
          message: 'Profile photo updated.',
          messageIsError: false,
          revision: state.revision + 1,
        ),
      );
    } catch (error) {
      _emitError(emit, error, AuthStatus.signedIn);
    }
  }

  Future<void> _changePassword(
    AuthPasswordChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.submitting, clearMessage: true));
    try {
      await _repository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(
        state.copyWith(
          status: AuthStatus.signedIn,
          message: 'Password updated.',
          messageIsError: false,
          revision: state.revision + 1,
        ),
      );
    } catch (error) {
      _emitError(emit, error, AuthStatus.signedIn);
    }
  }

  void _emitError(Emitter<AuthState> emit, Object error, AuthStatus fallback) {
    final message = error is AuthFailure
        ? error.message
        : 'The request could not be completed. Try again.';
    emit(
      state.copyWith(
        status: fallback,
        message: message,
        messageIsError: true,
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _logAuthEvent(String name) async {
    try {
      await _telemetry.logEvent(
        name,
        parameters: const {'method': 'email_password'},
      );
    } catch (_) {
      // Monitoring must not block account operations.
    }
  }

  @override
  Future<void> close() async {
    await _sessionSubscription.cancel();
    await super.close();
  }
}
