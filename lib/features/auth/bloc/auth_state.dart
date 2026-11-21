import '../../../data/auth_repository.dart';

enum AuthStatus { checking, signedOut, signedIn, submitting }

class AuthState {
  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.message,
    this.messageIsError = false,
    this.revision = 0,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? message;
  final bool messageIsError;
  final int revision;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool clearUser = false,
    String? message,
    bool clearMessage = false,
    bool? messageIsError,
    int? revision,
  }) => AuthState(
    status: status ?? this.status,
    user: clearUser ? null : user ?? this.user,
    message: clearMessage ? null : message ?? this.message,
    messageIsError: messageIsError ?? this.messageIsError,
    revision: revision ?? this.revision,
  );
}
