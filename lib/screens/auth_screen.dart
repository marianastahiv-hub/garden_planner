import 'package:flutter/material.dart';

const _green = Color(0xFF3F704F);
const _paper = Color(0xFFF9F9F7);

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onAuthenticated,
  });
  final ValueChanged<({String name, String email, String password})> onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController(text: 'hello@gardenlover.com');
  final _password = TextEditingController();
  bool _createAccount = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAuthenticated((
      name: _name.text.trim(),
      email: _createAccount ? _email.text.trim() : 'hello@gardenlover.com',
      password: _password.text,
    ));
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
      builder: (_) => const _PasswordRecoverySheet(),
    );

    if (email != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo only: no recovery email was sent.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 58, 24, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Center(child: Column(children: [
                    Container(width: 68, height: 68, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(19)), child: const Icon(Icons.spa_outlined, size: 38, color: Colors.white)),
                    const SizedBox(height: 14),
                    const Text('SproutPlan', style: TextStyle(fontFamily: 'Serif', fontSize: 38, color: _green)),
                    const SizedBox(height: 4),
                    const Text('Your mindful garden companion', style: TextStyle(color: Color(0xFF68766D))),
                  ])),
                  const SizedBox(height: 38),
                  ...[
                    _Label(_createAccount ? 'Your Name' : 'Nickname'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration('e.g. Sarah Jenkins'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Enter a nickname'
                          : null,
                    ),
                    if (_createAccount) ...[
                      const SizedBox(height: 16),
                      const _Label('Email Address'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('hello@gardenlover.com'),
                        validator: _validateEmail,
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                  const _Label('Password'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration('At least 8 characters').copyWith(
                      suffixIcon: IconButton(onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.lock_outline : Icons.lock_open_outlined, color: const Color(0xFF87968C))),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter a password'
                        : _createAccount && value.length < 8
                            ? 'Use at least 8 characters'
                            : null,
                  ),
                  if (!_createAccount) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _forgotPassword, child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFFE88964), decoration: TextDecoration.underline)))),
                  SizedBox(height: _createAccount ? 26 : 24),
                  SizedBox(width: double.infinity, child: FilledButton(onPressed: _submit, style: FilledButton.styleFrom(backgroundColor: _green, padding: const EdgeInsets.symmetric(vertical: 15)), child: Text(_createAccount ? 'Create Account' : 'Login', style: const TextStyle(fontWeight: FontWeight.w700)))),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => setState(() => _createAccount = !_createAccount), style: OutlinedButton.styleFrom(foregroundColor: _green, side: const BorderSide(color: _green, width: 1.3), padding: const EdgeInsets.symmetric(vertical: 14)), child: Text(_createAccount ? 'Back to Login' : 'Create New Account', style: const TextStyle(fontWeight: FontWeight.w700)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordRecoverySheet extends StatefulWidget {
  const _PasswordRecoverySheet();

  @override
  State<_PasswordRecoverySheet> createState() => _PasswordRecoverySheetState();
}

class _PasswordRecoverySheetState extends State<_PasswordRecoverySheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            22,
            12,
            22,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE4DD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 23,
                    color: Color(0xFF1E3326),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the email address connected to your account.',
                  style: TextStyle(color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 18),
                const _Label('Email Address'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _continue(),
                  decoration: _inputDecoration('name@example.com'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: _green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
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
  if (value == null || value.trim().isEmpty) return 'Enter your email address';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) return 'Enter a valid email address';
  return null;
}
