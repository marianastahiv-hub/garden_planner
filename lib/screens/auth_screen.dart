import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/auth_repository.dart';

const _green = Color(0xFF3F704F);
const _paper = Color(0xFFF9F9F7);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AuthRepository();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _createAccount = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_createAccount) {
        await _repository.signUp(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
      } else {
        await _repository.signIn(
          email: _email.text,
          password: _password.text,
        );
      }

      // Подія надсилається лише після успішної відповіді Firebase Auth.
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: _createAccount ? 'sign_up_succeeded' : 'login_succeeded',
        );
      } catch (error) {
        // Analytics не повинен зупиняти успішну авторизацію.
        debugPrint('Firebase Analytics event failed: $error');
      }
    } on FirebaseAuthException catch (error) {
      _showMessage(_authErrorMessage(error.code));
    } catch (_) {
      _showMessage('Не вдалося виконати запит. Перевірте інтернет і спробуйте ще раз.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ResetPasswordSheet(initialEmail: _email.text.trim()),
    );
    if (email == null || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await _repository.sendPasswordResetEmail(email: email);
      _showMessage('Лист для скидання пароля надіслано на $email.');
    } on FirebaseAuthException catch (error) {
      _showMessage(_authErrorMessage(error.code));
    } catch (_) {
      _showMessage('Не вдалося надіслати лист. Перевірте інтернет і спробуйте ще раз.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(19)),
                        child: const Icon(Icons.spa_outlined, size: 38, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      const Text('SproutPlan', style: TextStyle(fontFamily: 'Serif', fontSize: 38, color: _green)),
                      const SizedBox(height: 4),
                      const Text('Your mindful garden companion', style: TextStyle(color: Color(0xFF68766D))),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                if (_createAccount) ...[
                  const _FieldLabel('Name'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration('Your name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Введіть ім’я'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
                const _FieldLabel('Email Address'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: _inputDecoration('name@example.com'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: _inputDecoration('At least 6 characters').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword ? Icons.lock_outline : Icons.lock_open_outlined, color: const Color(0xFF87968C)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Введіть пароль';
                    if (_createAccount && value.length < 6) return 'Пароль має містити щонайменше 6 символів';
                    return null;
                  },
                ),
                if (!_createAccount)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _forgotPassword,
                      child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFFE88964), decoration: TextDecoration.underline)),
                    ),
                  ),
                SizedBox(height: _createAccount ? 26 : 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: _green, padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_createAccount ? 'Create Account' : 'Login', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => setState(() => _createAccount = !_createAccount),
                    style: OutlinedButton.styleFrom(foregroundColor: _green, side: const BorderSide(color: _green, width: 1.3), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(_createAccount ? 'Back to Login' : 'Create New Account', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordSheet extends StatefulWidget {
  const _ResetPasswordSheet({required this.initialEmail});
  final String initialEmail;

  @override
  State<_ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<_ResetPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(22, 12, 22, MediaQuery.viewInsetsOf(context).bottom + 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE4DD), borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 20),
                const Text('Reset Password', style: TextStyle(fontFamily: 'Serif', fontSize: 23, color: Color(0xFF1E3326))),
                const SizedBox(height: 8),
                const Text('Введіть email, прив’язаний до акаунта. Firebase надішле лист для скидання пароля.', style: TextStyle(color: Colors.black54, height: 1.4)),
                const SizedBox(height: 18),
                const _FieldLabel('Email Address'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration('name@example.com'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop(_emailController.text.trim());
                      }
                    },
                    style: FilledButton.styleFrom(backgroundColor: _green, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Send reset email'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF59635B)));
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDCE4DC))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDCE4DC))),
    );

String? _validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Введіть email';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) return 'Введіть email у правильному форматі';
  return null;
}

String _authErrorMessage(String code) => switch (code) {
      'invalid-email' => 'Некоректний формат email.',
      'email-already-in-use' => 'Акаунт із таким email уже існує.',
      'weak-password' => 'Пароль надто простий. Використайте щонайменше 6 символів.',
      'user-not-found' => 'Акаунт із таким email не знайдено.',
      'wrong-password' || 'invalid-credential' => 'Неправильний email або пароль.',
      'user-disabled' => 'Цей акаунт вимкнено.',
      'too-many-requests' => 'Забагато спроб. Спробуйте пізніше.',
      'network-request-failed' => 'Немає з’єднання. Перевірте інтернет.',
      'operation-not-allowed' => 'У Firebase Console не ввімкнений вхід Email/Password.',
      'invalid-action-code' || 'expired-action-code' => 'Посилання для скидання пароля недійсне або застаріло.',
      _ => 'Не вдалося виконати дію. Спробуйте ще раз.',
    };
