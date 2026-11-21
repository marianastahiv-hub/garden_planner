import 'dart:async';

import 'auth_repository.dart';

/// Optional in-memory adapter for demos and isolated Bloc/UI development.
/// Swap it for FirebaseAuthRepository in RepositoryProvider to run offline.
class InMemoryAuthRepository implements AuthRepository {
  final Map<String, _Account> _accounts = {};
  final StreamController<AuthUser?> _changes = StreamController.broadcast();
  AuthUser? _current;

  @override
  Stream<AuthUser?> get authStateChanges =>
      Stream<AuthUser?>.multi((controller) {
        controller.add(_current);
        final subscription = _changes.stream.listen(
          controller.add,
          onError: controller.addError,
        );
        controller.onCancel = subscription.cancel;
      });

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthFailure(
        'email-already-in-use',
        'An account with this email already exists.',
      );
    }
    if (password.length < 6) {
      throw const AuthFailure('weak-password', 'Choose a stronger password.');
    }
    final account = _Account(
      user: AuthUser(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        email: email.trim(),
        displayName: name.trim(),
      ),
      password: password,
    );
    _accounts[key] = account;
    _setCurrent(account.user);
    return account.user;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthFailure(
        'invalid-credential',
        'Email or password is incorrect.',
      );
    }
    _setCurrent(account.user);
    return account.user;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (!_accounts.containsKey(email.trim().toLowerCase())) {
      throw const AuthFailure(
        'user-not-found',
        'No account was found for this email.',
      );
    }
  }

  @override
  Future<void> signOut() async => _setCurrent(null);

  @override
  Future<void> updateDisplayName(String name) async {
    final account = _requireAccount();
    final user = AuthUser(
      id: account.user.id,
      email: account.user.email,
      displayName: name.trim(),
      photoUrl: account.user.photoUrl,
    );
    _replaceCurrent(account, user);
  }

  @override
  Future<void> updatePhotoUrl(String photoUrl) async {
    final account = _requireAccount();
    final user = AuthUser(
      id: account.user.id,
      email: account.user.email,
      displayName: account.user.displayName,
      photoUrl: photoUrl,
    );
    _replaceCurrent(account, user);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final account = _requireAccount();
    if (account.password != currentPassword) {
      throw const AuthFailure(
        'wrong-password',
        'Current password is incorrect.',
      );
    }
    if (newPassword.length < 8) {
      throw const AuthFailure('weak-password', 'Choose a stronger password.');
    }
    account.password = newPassword;
  }

  _Account _requireAccount() {
    final user = _current;
    final account = user == null ? null : _accounts[user.email.toLowerCase()];
    if (account == null) {
      throw const AuthFailure('not-signed-in', 'Please sign in again.');
    }
    return account;
  }

  void _replaceCurrent(_Account account, AuthUser user) {
    account.user = user;
    _setCurrent(user);
  }

  void _setCurrent(AuthUser? user) {
    _current = user;
    _changes.add(user);
  }
}

class _Account {
  _Account({required this.user, required this.password});

  AuthUser user;
  String password;
}
