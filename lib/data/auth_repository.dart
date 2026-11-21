/// User identity exposed to presentation and business-logic layers.
/// It intentionally contains no Firebase types.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
}

/// Stable application-level error. Data adapters translate provider-specific
/// errors into this type before they reach a Bloc or a widget.
class AuthFailure implements Exception {
  const AuthFailure(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Contract for account operations. Firebase, mock or another provider can
/// implement it without changing UI or Bloc code.
abstract interface class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;

  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthUser> signIn({required String email, required String password});
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> signOut();
  Future<void> updateDisplayName(String name);
  Future<void> updatePhotoUrl(String photoUrl);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
