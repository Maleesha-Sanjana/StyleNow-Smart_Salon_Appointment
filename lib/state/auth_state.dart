import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/main_scaffold.dart';
import '../screens/profile/profile_page.dart';

/// Reflects real Firebase auth state
final ValueNotifier<bool> isLoggedIn = ValueNotifier(
  FirebaseAuth.instance.currentUser != null,
);

/// Listen to Firebase auth changes and keep isLoggedIn in sync
void initAuthListener() {
  FirebaseAuth.instance.authStateChanges().listen((user) {
    isLoggedIn.value = user != null;
  });
}

/// Shows "Login to access this feature" popup.
/// Tapping Login → switches to Profile tab and opens the login sheet.
void showGuestRestrictionPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 48, color: Color(0xFFC9A84C)),
          const SizedBox(height: 16),
          const Text(
            'Login Required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Login to access this feature',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2D2D2D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF2D2D2D)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    mainNavIndex.value = 4;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showLoginSheet(context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    foregroundColor: const Color(0xFF2D2D2D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Call this before any restricted action.
/// Returns true if allowed, false if guest (and shows popup).
bool guardAction(BuildContext context) {
  if (isLoggedIn.value) return true;
  showGuestRestrictionPopup(context);
  return false;
}
