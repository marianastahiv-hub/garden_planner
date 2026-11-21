import '../../../data/auth_repository.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthStatusChanged extends AuthEvent {
  const AuthStatusChanged(this.user);
  final AuthUser? user;
}

final class AuthSignInSubmitted extends AuthEvent {
  const AuthSignInSubmitted({required this.email, required this.password});
  final String email;
  final String password;
}

final class AuthSignUpSubmitted extends AuthEvent {
  const AuthSignUpSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
}

final class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested(this.email);
  final String email;
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthDisplayNameChanged extends AuthEvent {
  const AuthDisplayNameChanged(this.name);
  final String name;
}

final class AuthPhotoChanged extends AuthEvent {
  const AuthPhotoChanged(this.photoUrl);
  final String photoUrl;
}

final class AuthPasswordChanged extends AuthEvent {
  const AuthPasswordChanged({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;
}
