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

  Future<void> _sendPasswordReset(String email) async {
    setState(() => _sendingReset = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _sendingReset = false);
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? '';
    final email = user?.email ?? '';
    final hasPassword =
        user?.providerData.any((p) => p.providerId == 'password') ?? false;

    return SubPageScaffold(
      title: 'Settings',
      body: ListView(
        children: [
          // Appearance section
          _sectionHeader('Appearance'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, mode, _) {
                return ListTile(
                  leading: const Icon(
                    Icons.dark_mode_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: mode == ThemeMode.dark,
                    activeColor: AppColors.accent,
                    onChanged: (value) {
                      themeNotifier.value = value
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                  ),
                );
              },
            ),
          ),

          // Account section
          _sectionHeader('Account'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: AppColors.accent,
                  ),
                  title: const Text('Name'),
                  subtitle: Text(displayName),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.email_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
                if (hasPassword)
                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline,
                      color: AppColors.accent,
                    ),
                    title: const Text('Change Password'),
                    trailing: _sendingReset
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _sendingReset
                        ? null
                        : () => _sendPasswordReset(email),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
