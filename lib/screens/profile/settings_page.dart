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
  // Security
  bool _sendingReset = false;
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;
  bool _loginAlertsEnabled = true;

  // Notifications
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _bookingReminders = true;
  bool _promotionalOffers = true;
  bool _newSalonAlerts = false;

  // Preferences
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'LKR';
  String _selectedRadius = '5 km';
  bool _locationEnabled = true;
  bool _autoConfirmBooking = false;

  // Linked accounts
  bool _googleLinked = false;
  bool _appleLinked = false;

  final _languages = ['English', 'Sinhala', 'Tamil'];
  final _currencies = ['LKR', 'USD', 'EUR', 'GBP'];
  final _radii = ['1 km', '2 km', '5 km', '10 km', '20 km'];

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.accent),
            const SizedBox(width: 6),
          ],
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 52, endIndent: 16);

  // ── Dialogs ───────────────────────────────────────────────────────────────

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

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true, obscureNew = true, obscureConfirm = true;
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
              platform: 'iPhone · Colombo, LK',
              icon: Icons.phone_iphone,
              isCurrent: true,
            ),
            _SessionTile(
              device: 'Chrome on Windows',
              platform: 'Web · 2 days ago',
              icon: Icons.computer,
              isCurrent: false,
            ),
            _SessionTile(
              device: 'Samsung Galaxy',
              platform: 'Android · 5 days ago',
              icon: Icons.phone_android,
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

  void _showPickerSheet(
    String title,
    List<String> options,
    String current,
    ValueChanged<String> onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...options.map(
              (opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(opt),
                trailing: current == opt
                    ? const Icon(Icons.check_circle, color: AppColors.accent)
                    : null,
                onTap: () {
                  onSelect(opt);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out?'),
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
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

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
          // ── Profile Card ──
          _ProfileCard(
            name: displayName,
            email: email,
            onEdit: () => _showChangeNameDialog(user?.displayName ?? ''),
          ),

          // ── Appearance ──
          _sectionHeader('Appearance', icon: Icons.palette_outlined),
          _SettingsCard(
            children: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, _) => _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: mode == ThemeMode.dark ? 'On' : 'Off',
                  trailing: Switch(
                    value: mode == ThemeMode.dark,
                    activeThumbColor: AppColors.accent,
                    onChanged: (v) => themeNotifier.value = v
                        ? ThemeMode.dark
                        : ThemeMode.light,
                  ),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: _selectedLanguage,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPickerSheet(
                  'Language',
                  _languages,
                  _selectedLanguage,
                  (v) => setState(() => _selectedLanguage = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.attach_money_outlined,
                title: 'Currency',
                subtitle: _selectedCurrency,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPickerSheet(
                  'Currency',
                  _currencies,
                  _selectedCurrency,
                  (v) => setState(() => _selectedCurrency = v),
                ),
              ),
            ],
          ),

          // ── Notifications ──
          _sectionHeader('Notifications', icon: Icons.notifications_outlined),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: 'Alerts on your device',
                trailing: Switch(
                  value: _pushNotifications,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Updates sent to your email',
                trailing: Switch(
                  value: _emailNotifications,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _emailNotifications = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.sms_outlined,
                title: 'SMS Notifications',
                subtitle: 'Text message alerts',
                trailing: Switch(
                  value: _smsNotifications,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _smsNotifications = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.alarm_outlined,
                title: 'Booking Reminders',
                subtitle: 'Remind me before appointments',
                trailing: Switch(
                  value: _bookingReminders,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _bookingReminders = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.local_offer_outlined,
                title: 'Promotional Offers',
                subtitle: 'Deals and discounts',
                trailing: Switch(
                  value: _promotionalOffers,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _promotionalOffers = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.store_outlined,
                title: 'New Salon Alerts',
                subtitle: 'When new salons open nearby',
                trailing: Switch(
                  value: _newSalonAlerts,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _newSalonAlerts = v),
                ),
              ),
            ],
          ),

          // ── Booking Preferences ──
          _sectionHeader(
            'Booking Preferences',
            icon: Icons.calendar_today_outlined,
          ),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.location_on_outlined,
                title: 'Location Services',
                subtitle: _locationEnabled ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: _locationEnabled,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _locationEnabled = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.radar_outlined,
                title: 'Search Radius',
                subtitle: _selectedRadius,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPickerSheet(
                  'Search Radius',
                  _radii,
                  _selectedRadius,
                  (v) => setState(() => _selectedRadius = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.check_circle_outline,
                title: 'Auto-Confirm Bookings',
                subtitle: 'Skip confirmation step',
                trailing: Switch(
                  value: _autoConfirmBooking,
                  activeThumbColor: AppColors.accent,
                  onChanged: (v) => setState(() => _autoConfirmBooking = v),
                ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.history_outlined,
                title: 'Booking History',
                subtitle: 'View all past appointments',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Coming soon'),
              ),
            ],
          ),

          // ── Account ──
          _sectionHeader('Account', icon: Icons.person_outline),
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
                title: 'Email Address',
                subtitle: email,
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.phone_outlined,
                title: 'Phone Number',
                subtitle: 'Not set',
                trailing: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.accent,
                ),
                onTap: () => _showSnack('Coming soon'),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.cake_outlined,
                title: 'Date of Birth',
                subtitle: 'Not set',
                trailing: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.accent,
                ),
                onTap: () => _showSnack('Coming soon'),
              ),
            ],
          ),

          // ── Linked Accounts ──
          _sectionHeader('Linked Accounts', icon: Icons.link_outlined),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.g_mobiledata_rounded,
                title: 'Google',
                subtitle: _googleLinked ? 'Connected' : 'Not connected',
                iconColor: Colors.red,
                trailing: _googleLinked
                    ? TextButton(
                        onPressed: () => setState(() => _googleLinked = false),
                        child: const Text(
                          'Unlink',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => setState(() => _googleLinked = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Link',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.apple,
                title: 'Apple',
                subtitle: _appleLinked ? 'Connected' : 'Not connected',
                iconColor: Colors.black,
                trailing: _appleLinked
                    ? TextButton(
                        onPressed: () => setState(() => _appleLinked = false),
                        child: const Text(
                          'Unlink',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => setState(() => _appleLinked = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Link',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
              ),
            ],
          ),

          // ── Security ──
          _sectionHeader('Security', icon: Icons.security_outlined),
          _SettingsCard(
            children: [
              if (hasPassword) ...[
                _SettingsTile(
                  icon: Icons.lock_reset_outlined,
                  title: 'Change Password',
                  subtitle: 'Update your current password',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showChangePasswordDialog,
                ),
                _divider(),
                _SettingsTile(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Reset via Email',
                  subtitle: 'Send a password reset link',
                  trailing: _sendingReset
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
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
                    : 'Use fingerprint or Face ID',
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
                subtitle: 'Manage signed-in devices',
                trailing: const Icon(Icons.chevron_right),
                onTap: _showActiveSessionsSheet,
              ),
            ],
          ),

          // ── Privacy ──
          _sectionHeader('Privacy', icon: Icons.privacy_tip_outlined),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.visibility_outlined,
                title: 'Profile Visibility',
                subtitle: 'Public',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPickerSheet(
                  'Profile Visibility',
                  ['Public', 'Friends Only', 'Private'],
                  'Public',
                  (_) {},
                ),
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
                subtitle: 'Export a copy of your data',
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _showSnack('Your data export will be emailed to you'),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.cookie_outlined,
                title: 'Cookie Preferences',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Coming soon'),
              ),
            ],
          ),

          // ── Help & Support ──
          _sectionHeader('Help & Support', icon: Icons.help_outline),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.help_center_outlined,
                title: 'Help Center / FAQ',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Opening Help Center...'),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.chat_outlined,
                title: 'Contact Support',
                subtitle: 'Chat with our team',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Opening support chat...'),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.bug_report_outlined,
                title: 'Report a Bug',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Bug report form coming soon'),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.star_outline_rounded,
                title: 'Rate the App',
                subtitle: 'Enjoying StyleNow? Leave a review',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Redirecting to App Store...'),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.share_outlined,
                title: 'Share with Friends',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Share link copied!'),
              ),
            ],
          ),

          // ── About ──
          _sectionHeader('About', icon: Icons.info_outline),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Opening Terms of Service...'),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.policy_outlined,
                title: 'Privacy Policy',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnack('Opening Privacy Policy...'),
              ),
              _divider(),
              _SettingsTile(
                icon: Icons.gavel_outlined,
                title: 'Licenses',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(context: context),
              ),
              _divider(),
              const _SettingsTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: 'StyleNow v1.0.0 (Build 1)',
              ),
            ],
          ),

          // ── Sign Out ──
          _sectionHeader(
            'Account Actions',
            icon: Icons.manage_accounts_outlined,
          ),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                iconColor: Colors.orange,
                titleColor: Colors.orange,
                trailing: const Icon(Icons.chevron_right, color: Colors.orange),
                onTap: _showLogoutDialog,
              ),
              _divider(),
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

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Profile Card ───────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onEdit;

  const _ProfileCard({
    required this.name,
    required this.email,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.accent.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.accent),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
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
