import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../state/auth_state.dart';
import 'phone_auth_sheet.dart';
import 'my_bookings_page.dart';
import 'saved_salons_page.dart';
import 'my_reviews_page.dart';
import 'my_orders_page.dart';
import 'settings_page.dart';

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
    return ValueListenableBuilder<bool>(
      valueListenable: isLoggedIn,
      builder: (context, loggedIn, _) {
        if (loggedIn) return const _LoggedInProfile();
        return const _GuestProfile();
      },
    );
  }
}

// ─── Guest View ───────────────────────────────────────────────────────────────

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _ProfileHeader(
            topPadding: topPadding,
            name: 'Guest User',
            subtitle: 'Login to unlock all features',
            photoUrl: null,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
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

// ─── Logged-in View ───────────────────────────────────────────────────────────

class _LoggedInProfile extends StatefulWidget {
  const _LoggedInProfile();

  @override
  State<_LoggedInProfile> createState() => _LoggedInProfileState();
}

class _LoggedInProfileState extends State<_LoggedInProfile> {
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    // Reload user to ensure displayName and photoURL are up to date
    FirebaseAuth.instance.currentUser?.reload().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final ref = FirebaseStorage.instance.ref(
        'profile_photos/${user.uid}.jpg',
      );
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
      // Reload user so currentUser reflects new photoURL
      await user.reload();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update photo')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // Reload user each build to get fresh displayName/photoURL
    final user = FirebaseAuth.instance.currentUser;
    final topPadding = MediaQuery.of(context).padding.top;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final displayName = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!
        : user?.email?.split('@').first ?? 'User';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header with tappable photo
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
                const Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: AppColors.accent,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
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
                GestureDetector(
                  onTap: _uploading ? null : _changePhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent, width: 2),
                        ),
                        child: _uploading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.accent,
                                  strokeWidth: 2,
                                ),
                              )
                            : (photoUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 44,
                                    )),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(fontSize: 13, color: Colors.white60),
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
                  _tile(
                    context,
                    Icons.calendar_today_outlined,
                    'My Bookings',
                    textColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyBookingsPage()),
                    ),
                  ),
                  _tile(
                    context,
                    Icons.favorite_outline,
                    'Saved Salons',
                    textColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedSalonsPage(),
                      ),
                    ),
                  ),
                  _tile(
                    context,
                    Icons.star_outline,
                    'My Reviews',
                    textColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyReviewsPage()),
                    ),
                  ),
                  _tile(
                    context,
                    Icons.shopping_bag_outlined,
                    'My Orders',
                    textColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyOrdersPage()),
                    ),
                  ),
                  _tile(
                    context,
                    Icons.settings_outlined,
                    'Settings',
                    textColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    Color textColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
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
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Shared header (guest only) ───────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final double topPadding;
  final String name;
  final String subtitle;
  final String? photoUrl;

  const _ProfileHeader({
    required this.topPadding,
    required this.name,
    required this.subtitle,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.accent, size: 28),
              SizedBox(width: 12),
              Text(
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: photoUrl != null
                ? ClipOval(child: Image.network(photoUrl!, fit: BoxFit.cover))
                : const Icon(Icons.person, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

// ─── Login Sheet ──────────────────────────────────────────────────────────────

class _LoginSheet extends StatefulWidget {
  const _LoginSheet();

  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  File? _pickedImage;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _submit() async {
    // Validate Full Name required for signup
    if (!_isLogin && _nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Full Name is required.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
        // Reload so displayName is fresh on profile page
        await FirebaseAuth.instance.currentUser?.reload();
      } else {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );
        final user = cred.user!;
        await user.updateDisplayName(_nameCtrl.text.trim());
        // Upload profile photo if selected
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance.ref(
            'profile_photos/${user.uid}.jpg',
          );
          await ref.putFile(_pickedImage!);
          final url = await ref.getDownloadURL();
          await user.updatePhotoURL(url);
        }
        await user.reload();
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                        color: _isLogin
                            ? AppColors.primary
                            : Colors.transparent,
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
                        color: !_isLogin
                            ? AppColors.primary
                            : Colors.transparent,
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
            // Profile photo picker (signup only)
            if (!_isLogin) ...[
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: _pickedImage != null
                          ? ClipOval(
                              child: Image.file(
                                _pickedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 40,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Optional',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 14),
              _field(
                'Full Name',
                Icons.person_outline,
                controller: _nameCtrl,
                required: true,
              ),
              const SizedBox(height: 12),
            ],
            _field('Email', Icons.email_outlined, controller: _emailCtrl),
            const SizedBox(height: 12),
            _field(
              'Password',
              Icons.lock_outline,
              obscure: true,
              controller: _passwordCtrl,
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        _isLogin ? 'Login' : 'Create Account',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
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
                GestureDetector(
                  onTap: _loading ? null : _googleSignIn,
                  child: _socialBtn('G', Colors.red),
                ),
                const SizedBox(width: 16),
                _socialBtn('', Colors.black, icon: Icons.apple),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _loading
                      ? null
                      : () {
                          Navigator.pop(context);
                          showPhoneAuthSheet(context);
                        },
                  child: _socialBtn('📱', Colors.green),
                ),
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
      ),
    );
  }

  Widget _field(
    String hint,
    IconData icon, {
    bool obscure = false,
    TextEditingController? controller,
    bool required = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: required ? '$hint *' : hint,
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
