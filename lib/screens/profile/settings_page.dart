import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_sub_page_helpers.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _sendingReset = false;
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;
  bool _loginAlertsEnabled = true;

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  // ── Name Change ───────────────────────────────────────────────────────────

  void _showChangeNameDialog(String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Change Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Display Name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final newName = ctrl.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await FirebaseAuth.instance.currentUser?.updateDisplayName(
                  newName,
                );
                setState(() {});
                _showSnack('Name updated successfully');
              } catch (e) {
                _showSnack(e.toString(), error: true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  Future<void> _sendPasswordReset(String email) async {
    setState(() => _sendingReset = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnack('Password reset email sent to $email');
    } catch (e) {
      _showSnack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _sendingReset = false);
    }
  }

  // ── Change Password (in-app) ──────────────────────────────────────────────

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Change Password',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PasswordField(
                ctrl: currentCtrl,
                label: 'Current Password',
                obscure: obscureCurrent,
                onToggle: () =>
                    setDlgState(() => obscureCurrent = !obscureCurrent),
              ),
              const SizedBox(height: 12),
              _PasswordField(
                ctrl: newCtrl,
                label: 'New Password',
                obscure: obscureNew,
                onToggle: () => setDlgState(() => obscureNew = !obscureNew),
              ),
              const SizedBox(height: 12),
              _PasswordField(
                ctrl: confirmCtrl,
                label: 'Confirm New Password',
                obscure: obscureConfirm,
                onToggle: () =>
                    setDlgState(() => obscureConfirm = !obscureConfirm),
              ),
              const SizedBox(height: 4),
              const _PasswordStrengthHint(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: loading
                  ? null
                  : () async {
                      if (newCtrl.text != confirmCtrl.text) {
                        _showSnack('Passwords do not match', error: true);
                        return;
                      }
                      if (newCtrl.text.length < 8) {
                        _showSnack(
                          'Password must be at least 8 characters',
                          error: true,
                        );
                        return;
                      }
                      setDlgState(() => loading = true);
                      try {
                        final user = FirebaseAuth.instance.currentUser!;
                        final cred = EmailAuthProvider.credential(
                          email: user.email!,
                          password: currentCtrl.text,
                        );
                        await user.reauthenticateWithCredential(cred);
                        await user.updatePassword(newCtrl.text);
                        if (ctx.mounted) Navigator.pop(ctx);
                        _showSnack('Password changed successfully');
                      } catch (e) {
                        _showSnack(e.toString(), error: true);
                      } finally {
                        setDlgState(() => loading = false);
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Account ────────────────────────────────────────────────────────

  void _showDeleteAccountDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action is permanent and cannot be undone. All your data will be deleted.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: 'Type DELETE to confirm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (ctrl.text.trim() != 'DELETE') {
                _showSnack('Please type DELETE to confirm', error: true);
                return;
              }
              Navigator.pop(ctx);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
              } catch (e) {
                _showSnack(e.toString(), error: true);
              }
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  // ── Active Sessions Sheet ─────────────────────────────────────────────────

  void _showActiveSessionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _SessionTile(
              device: 'This device',
              platform: 'Android · Colombo, LK',
              icon: Icons.phone_android,
              isCurrent: true,
            ),
            _SessionTile(
              device: 'Chrome on Windows',
              platform: 'Web · 2 days ago',
              icon: Icons.computer,
              isCurrent: false,
            ),
            _SessionTile(
              device: 'iPhone 14',
              platform: 'iOS · 5 days ago',
              icon: Icons.phone_iphone,
              isCurrent: false,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign out all other sessions',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showSnack('Signed out of all other sessions');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'No name set';
    final email = user?.email ?? '';
    final hasPassword =
        user?.providerData.any((p) => p.providerId == 'password') ?? false;

    return SubPageScaffold(
      title: 'Settings',
      body: ListView(
        children: [
          // ── Appearance ──
          _sectionHeader('Appearance'),
          _SettingsCard(
            children: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, _) => _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: mode == ThemeMode.dark,
                    activeThumbColor: AppColors.accent,
                    onChanged: (v) => themeNotifier.value = v
                        ? ThemeMode.dark
                        : ThemeMode.light,
                  ),
                ),
              ),
            ],
          ),

          // ── Account ──
          _sectionHeader('Account'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Display Name',
                subtitle: displayName,
                trailing: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.accent,
                ),
                onTap: () => _showChangeNameDialog(user?.displayName ?? ''),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: email,
              ),
            ],
          ),

          // ── Security ──
          _sectionHeader('Security'),
          _SettingsCard(
            children: [
              if (hasPassword) ...[
                _SettingsTile(
                  icon: Icons.lock_reset_outlined,
                  title: 'Change Password',
                  subtitle: 'Update your current password',
                  trailing: _sendingReset
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _showChangePasswordDialog,
                ),
                _divider(),
                _SettingsTile(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Reset via Email',
                  subtitle: 'Send a password reset link',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _sendPasswordReset(email),
                ),
                _divider(),
              ],
              _SettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Two-Factor Authentication',
                subtitle: _twoFactorEnabled
                    ? 'Enabled'
                    : 'Add an extra layer of security',
                trailing: Switch(
                  value: _twoFactorEnabled,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _twoFactorEnabled = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.fingerprint,
                title: 'Biometric Lock',
                subtitle: _biometricEnabled
                    ? 'Enabled'
                    : 'Use fingerprint or face ID',
                trailing: Switch(
                  value: _biometricEnabled,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _biometricEnabled = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'Login Alerts',
                subtitle: 'Get notified of new sign-ins',
                trailing: Switch(
                  value: _loginAlertsEnabled,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _loginAlertsEnabled = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.devices_outlined,
                title: 'Active Sessions',
                subtitle: 'Manage devices signed into your account',
                trailing: const Icon(Icons.chevron_right),
                onTap: _showActiveSessionsSheet,
              ),
            ],
          ),

          // ── Privacy ──
          _sectionHeader('Privacy'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.visibility_outlined,
                title: 'Profile Visibility',
                subtitle: 'Public',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Coming soon'),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.block_outlined,
                title: 'Blocked Users',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Coming soon'),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'Download My Data',
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _showSnack('Your data export will be emailed to you'),
              ),
            ],
          ),

          // ── Danger Zone ──
          _sectionHeader('Danger Zone'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete Account',
                subtitle: 'Permanently remove your account and data',
                iconColor: Colors.red,
                titleColor: Colors.red,
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: _showDeleteAccountDialog,
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 52, endIndent: 16);
}

// ── Reusable Widgets ───────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.accent,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.ctrl,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

class _PasswordStrengthHint extends StatelessWidget {
  const _PasswordStrengthHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 4),
          _Hint(text: 'Be at least 8 characters'),
          _Hint(text: 'Include a number or symbol'),
          _Hint(text: 'Not be your previous password'),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 13, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final String device;
  final String platform;
  final IconData icon;
  final bool isCurrent;

  const _SessionTile({
    required this.device,
    required this.platform,
    required this.icon,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isCurrent ? AppColors.accent : Colors.grey),
      title: Row(
        children: [
          Text(device, style: const TextStyle(fontWeight: FontWeight.w500)),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Current',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(platform, style: const TextStyle(fontSize: 12)),
      trailing: isCurrent
          ? null
          : TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Sign out',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
    );
  }
}
