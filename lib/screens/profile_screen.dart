import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _green = Color(0xFF3F704F);
const _paper = Color(0xFFF9F9F7);
const _ink = Color(0xFF1E3326);

// Профіль показує дані Firebase-користувача й надає керування акаунтом.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.onLogout,
    required this.onPasswordChanged,
    required this.onNameChanged,
    required this.onPhotoChanged,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final VoidCallback onLogout;
  final Future<void> Function(String currentPassword, String newPassword) onPasswordChanged;
  final Future<void> Function(String name) onNameChanged;
  final Future<void> Function(String photoUrl) onPhotoChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _hideCurrent = true;
  bool _hideNext = true;
  late String _displayName;
  bool _isSavingPassword = false;
  bool _isSavingProfile = false;

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

  // Змінюємо ім'я Firebase-профілю; userChanges оновить також дашборд.
  Future<void> _editName() async {
    final updatedName = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialName: _displayName),
    );
    if (updatedName == null || !mounted) return;
    setState(() => _isSavingProfile = true);
    try {
      await widget.onNameChanged(updatedName);
      if (!mounted) return;
      setState(() => _displayName = updatedName);
      _message('Name updated.');
    } on FirebaseAuthException catch (error) {
      _message(_authMessage(error.code));
    } catch (_) {
      _message('Could not update name. Please try again.');
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _choosePhoto() async {
    const photos = <String>[
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300&h=300&fit=crop&crop=faces',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=300&fit=crop&crop=faces',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop&crop=faces',
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _paper,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Choose a profile photo', style: TextStyle(fontFamily: 'Serif', fontSize: 21, color: _ink)),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: photos.map((url) => GestureDetector(
              onTap: () => Navigator.pop(context, url),
              child: CircleAvatar(radius: 35, backgroundImage: NetworkImage(url)),
            )).toList()),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _isSavingProfile = true);
    try {
      await widget.onPhotoChanged(selected);
      if (mounted) _message('Profile photo updated.');
    } on FirebaseAuthException catch (error) {
      if (mounted) _message(_authMessage(error.code));
    } catch (_) {
      if (mounted) _message('Could not update profile photo. Please try again.');
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_current.text.isEmpty || _next.text.length < 8) {
      _message(_current.text.isEmpty ? 'Enter your current password.' : 'New password must have at least 8 characters.');
      return;
    }
    setState(() => _isSavingPassword = true);
    try {
      await widget.onPasswordChanged(_current.text, _next.text);
      if (!mounted) return;
      _current.clear();
      _next.clear();
      _message('Password updated.');
    } on FirebaseAuthException catch (error) {
      _message(_authMessage(error.code));
    } catch (_) {
      _message('Could not update password. Please try again.');
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

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
                      Stack(alignment: Alignment.bottomRight, children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: const Color(0xFFE4EEE6),
                          backgroundImage: widget.photoUrl == null ? null : NetworkImage(widget.photoUrl!),
                          child: widget.photoUrl == null ? const Icon(Icons.person, size: 54, color: _green) : null,
                        ),
                        IconButton.filled(
                          onPressed: _isSavingProfile ? null : _choosePhoto,
                          tooltip: 'Choose profile photo',
                          icon: const Icon(Icons.camera_alt_outlined, size: 17),
                          style: IconButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, visualDensity: VisualDensity.compact),
                        ),
                      ]),
                      if (_isSavingProfile) const Padding(padding: EdgeInsets.only(top: 6), child: LinearProgressIndicator(minHeight: 2)),
                      SizedBox(height: 12),
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
                  onPressed: _isSavingPassword ? null : _changePassword,
                  style: FilledButton.styleFrom(foregroundColor: _green, backgroundColor: const Color(0xFFE7F0E9)),
                  child: _isSavingPassword ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Update Password'),
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

String _authMessage(String code) => switch (code) {
      'wrong-password' || 'invalid-credential' => 'Current password is incorrect.',
      'requires-recent-login' => 'Please sign out and sign in again, then retry this change.',
      'weak-password' => 'Choose a stronger password with at least 8 characters.',
      'network-request-failed' => 'Check your internet connection and try again.',
      'user-not-found' => 'Could not find the signed-in account. Please sign in again.',
      _ => 'Could not update your account. Please try again.',
    };
