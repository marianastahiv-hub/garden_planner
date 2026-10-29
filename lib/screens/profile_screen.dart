import 'package:flutter/material.dart';

const _green = Color(0xFF3F704F);
const _paper = Color(0xFFF9F9F7);
const _ink = Color(0xFF1E3326);

// Профіль показує дані демо-користувача та дозволяє змінити ім'я/пароль.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.onLogout,
    required this.onPasswordChanged,
    required this.onNameChanged,
  });

  final String name;
  final String email;
  final String password;
  final VoidCallback onLogout;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onNameChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _hideCurrent = true;
  bool _hideNext = true;
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = widget.name;
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) _displayName = widget.name;
  }

  // Відкриваємо окремий діалог; після Save оновлюємо профіль і дашборд.
  Future<void> _editName() async {
    final updatedName = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialName: _displayName),
    );
    if (updatedName != null && mounted) {
      setState(() => _displayName = updatedName);
      widget.onNameChanged(updatedName);
    }
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  // Демо-перевірка пароля в пам'яті, без серверної авторизації.
  void _changePassword() {
    if (_current.text != widget.password) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current password is incorrect.')));
      return;
    }
    if (_next.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New password must have at least 8 characters.')));
      return;
    }
    widget.onPasswordChanged(_next.text);
    _current.clear();
    _next.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _paper,
        appBar: AppBar(
          backgroundColor: _paper,
          title: const Text('Profile', style: TextStyle(fontFamily: 'Serif', fontSize: 25, color: _ink)),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFFE4EEE6),
                        child: const Icon(Icons.person, size: 54, color: _green),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              _displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Serif', fontSize: 23, color: _ink),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit name',
                            onPressed: _editName,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.edit_outlined, size: 18, color: _green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(widget.email, style: const TextStyle(color: Color(0xFF68766D))),
                    ],
                  ),
                ),
                const SizedBox(height: 38),
                const Text('Change Password', style: TextStyle(fontFamily: 'Serif', fontSize: 21, color: _ink)),
                const SizedBox(height: 18),
                const _FieldLabel('Current Password'),
                const SizedBox(height: 6),
                TextField(
                  controller: _current,
                  obscureText: _hideCurrent,
                  decoration: _decoration('Enter current password').copyWith(
                    suffixIcon: IconButton(onPressed: () => setState(() => _hideCurrent = !_hideCurrent), icon: Icon(_hideCurrent ? Icons.lock_outline : Icons.lock_open_outlined, color: const Color(0xFF87968C))),
                  ),
                ),
                const SizedBox(height: 14),
                const _FieldLabel('New Password'),
                const SizedBox(height: 6),
                TextField(
                  controller: _next,
                  obscureText: _hideNext,
                  decoration: _decoration('At least 8 characters').copyWith(
                    suffixIcon: IconButton(onPressed: () => setState(() => _hideNext = !_hideNext), icon: Icon(_hideNext ? Icons.lock_outline : Icons.lock_open_outlined, color: const Color(0xFF87968C))),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: _changePassword,
                  style: FilledButton.styleFrom(foregroundColor: _green, backgroundColor: const Color(0xFFE7F0E9)),
                  child: const Text('Update Password'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.onLogout,
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE88964), side: const BorderSide(color: Color(0xFFE88964)), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Log Out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName});
  final String initialName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (_) => _save(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      );

  void _save() {
    final name = _controller.text.trim();
    if (name.isNotEmpty && mounted) {
      Navigator.of(context).pop(name);
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF59635B)));
}

InputDecoration _decoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDCE4DC))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDCE4DC))),
    );
