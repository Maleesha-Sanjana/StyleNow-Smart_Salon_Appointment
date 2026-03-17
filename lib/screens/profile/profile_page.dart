import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Call this from anywhere to open the login/signup bottom sheet
void showLoginSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LoginSheet(),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 28),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      color: AppColors.accent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Guest avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Guest User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Login to unlock all features',
                  style: TextStyle(fontSize: 13, color: Colors.white60),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Login / Signup buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => showLoginSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => showLoginSheet(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Locked features list
                  _lockedTile(
                    context,
                    Icons.calendar_today_outlined,
                    'My Bookings',
                    textColor,
                  ),
                  _lockedTile(
                    context,
                    Icons.favorite_outline,
                    'Saved Salons',
                    textColor,
                  ),
                  _lockedTile(
                    context,
                    Icons.star_outline,
                    'My Reviews',
                    textColor,
                  ),
                  _lockedTile(
                    context,
                    Icons.shopping_bag_outlined,
                    'My Orders',
                    textColor,
                  ),
                  _lockedTile(
                    context,
                    Icons.settings_outlined,
                    'Settings',
                    textColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockedTile(
    BuildContext context,
    IconData icon,
    String label,
    Color textColor,
  ) {
    return GestureDetector(
      onTap: () => showLoginSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
            ),
            const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LoginSheet extends StatefulWidget {
  const _LoginSheet();

  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isLogin = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isLogin ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isLogin ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isLogin = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isLogin ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !_isLogin ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!_isLogin) ...[
            _field('Full Name', Icons.person_outline),
            const SizedBox(height: 12),
          ],
          _field('Email', Icons.email_outlined),
          const SizedBox(height: 12),
          _field('Password', Icons.lock_outline, obscure: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _isLogin ? 'Login' : 'Create Account',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Social login
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialBtn('G', Colors.red),
              const SizedBox(width: 16),
              _socialBtn('', Colors.black, icon: Icons.apple),
              const SizedBox(width: 16),
              _socialBtn('📱', Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Continue as Guest',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.accent),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _socialBtn(String label, Color color, {IconData? icon}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: color, size: 24)
            : Text(
                label,
                style: TextStyle(
                  fontSize: label.length == 1 ? 18 : 22,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
