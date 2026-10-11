import 'package:flutter/material.dart';

const _green = Color(0xFF3F704F);
const _paper = Color(0xFFF9F9F7);

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onAuthenticated,
    this.savedEmail,
    this.savedPassword,
  });
  final ValueChanged<({String name, String email, String password})> onAuthenticated;
  final String? savedEmail;
  final String? savedPassword;

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
  void initState() {
    super.initState();
    if (widget.savedEmail != null) _email.text = widget.savedEmail!;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_createAccount && widget.savedEmail != null &&
        (_email.text.trim().toLowerCase() != widget.savedEmail!.toLowerCase() ||
            _password.text != widget.savedPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email or password is incorrect.')),
      );
      return;
    }
    if (!_createAccount && widget.savedEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create an account to get started.')),
      );
      return;
    }
    widget.onAuthenticated((
      name: _createAccount && _name.text.trim().isNotEmpty
          ? _name.text.trim()
          : 'Sarah Jenkins',
      email: _email.text.trim(),
      password: _password.text,
    ));
  }

  void _forgotPassword() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password recovery will be available later.')),
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
                  if (_createAccount) ...[
                    const _Label('Your Name'),
                    const SizedBox(height: 6),
                    TextFormField(controller: _name, textCapitalization: TextCapitalization.words, decoration: _inputDecoration('Sarah Jenkins'), validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name' : null),
                    const SizedBox(height: 16),
                  ],
                  const _Label('Email Address'),
                  const SizedBox(height: 6),
                  TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration('hello@gardenlover.com'), validator: _validateEmail),
                  const SizedBox(height: 16),
                  const _Label('Password'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration('At least 8 characters').copyWith(
                      suffixIcon: IconButton(onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.lock_outline : Icons.lock_open_outlined, color: const Color(0xFF87968C))),
                    ),
                    validator: (value) => value == null || value.length < 8 ? 'Use at least 8 characters' : null,
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
