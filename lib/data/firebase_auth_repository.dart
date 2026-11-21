import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'auth_repository.dart';

/// Firebase implementation of the provider-independent AuthRepository.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({firebase.FirebaseAuth? auth})
    : _auth = auth ?? firebase.FirebaseAuth.instance;

  final firebase.FirebaseAuth _auth;

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.userChanges().map(_toAuthUser);

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      return _toAuthUser(credential.user)!;
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _toAuthUser(credential.user)!;
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name.trim());
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      await _auth.currentUser?.updatePhotoURL(photoUrl);
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      final email = user?.email;
      if (user == null || email == null) {
        throw const AuthFailure('not-signed-in', 'Please sign in again.');
      }
      final credential = firebase.EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on firebase.FirebaseAuthException catch (error) {
      throw _mapError(error);
    }
  }

  AuthFailure _mapError(firebase.FirebaseAuthException error) {
    final message = switch (error.code) {
      'invalid-email' => 'Email address is not valid.',
      'email-already-in-use' => 'An account with this email already exists.',
      'weak-password' => 'Choose a stronger password.',
      'user-not-found' => 'No account was found for this email.',
      'wrong-password' ||
      'invalid-credential' => 'Email or password is incorrect.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      'network-request-failed' => 'Connection failed. Check your internet.',
      'operation-not-allowed' => 'Email and password sign-in is disabled.',
      'requires-recent-login' =>
        'Sign in again before changing this account detail.',
      'invalid-action-code' ||
      'expired-action-code' => 'This password reset link has expired.',
      _ => 'The account request could not be completed.',
    };
    return AuthFailure(error.code, message);
  }

  AuthUser? _toAuthUser(firebase.User? user) => user == null
      ? null
      : AuthUser(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
}
