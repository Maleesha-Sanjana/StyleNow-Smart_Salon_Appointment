# Implementation Plan: Profile Sub-Pages

## Overview

Implement five profile sub-pages (My Bookings, Saved Salons, My Reviews, My Orders, Settings) as self-contained Flutter widgets with Firestore streaming, then wire navigation from `profile_page.dart`.

## Tasks

- [x] 1. Create shared helpers
  - [x] 1.1 Create `_SubPageScaffold` and `_StatusChip` widgets in a shared file `lib/screens/profile/profile_sub_page_helpers.dart`
    - `_SubPageScaffold`: wraps body in a `Scaffold` with an `AppBar` using `AppColors.primary` background, white title text, and a back button
    - `_StatusChip`: maps status string to a background colour and renders a rounded chip label
    - _Requirements: 7.1, 7.2_

- [x] 2. Implement MyBookingsPage
  - [x] 2.1 Create `lib/screens/profile/my_bookings_page.dart`
    - `StatelessWidget` using `_SubPageScaffold` with title "My Bookings"
    - `StreamBuilder<QuerySnapshot>` on `bookings` collection filtered by `userId == uid`
    - Loading state: `CircularProgressIndicator`
    - Error state: error message `Text`
    - Empty state: icon + "No bookings yet" message
    - Data state: `ListView.builder` of cards showing salonName, serviceName, date, time, and `_StatusChip(status)`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 7.1, 7.2, 7.3_

  - [ ]* 2.2 Write unit tests for MyBookingsPage states
    - Test loading, empty, error, and data states with mocked Firestore stream
    - _Requirements: 2.4, 2.5, 2.6_

- [x] 3. Implement SavedSalonsPage
  - [x] 3.1 Create `lib/screens/profile/saved_salons_page.dart`
    - `StatelessWidget` using `_SubPageScaffold` with title "Saved Salons"
    - `StreamBuilder<QuerySnapshot>` on `saved_salons` collection filtered by `userId == uid`
    - Loading, error, and empty states following the same pattern as MyBookingsPage
    - Data state: `ListView.builder` of cards showing salonName, `Image.network(imageUrl)`, and star rating row
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 7.1, 7.2, 7.3_

  - [ ]* 3.2 Write unit tests for SavedSalonsPage states
    - Test loading, empty, error, and data states
    - _Requirements: 3.4, 3.5, 3.6_

- [x] 4. Implement MyReviewsPage
  - [x] 4.1 Create `lib/screens/profile/my_reviews_page.dart`
    - `StatelessWidget` using `_SubPageScaffold` with title "My Reviews"
    - `StreamBuilder<QuerySnapshot>` on `reviews` collection filtered by `userId == uid`
    - Loading, error, and empty states following the same pattern
    - Data state: `ListView.builder` of cards showing salonName, star rating row, comment, and date
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 7.1, 7.2, 7.3_

  - [ ]* 4.2 Write unit tests for MyReviewsPage states
    - Test loading, empty, error, and data states
    - _Requirements: 4.4, 4.5, 4.6_

- [x] 5. Implement MyOrdersPage
  - [x] 5.1 Create `lib/screens/profile/my_orders_page.dart`
    - `StatelessWidget` using `_SubPageScaffold` with title "My Orders"
    - `StreamBuilder<QuerySnapshot>` on `orders` collection filtered by `userId == uid`
    - Loading, error, and empty states following the same pattern
    - Data state: `ListView.builder` of cards showing productName, date, formatted total, and `_StatusChip(status)`
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 7.1, 7.2, 7.3_

  - [ ]* 5.2 Write unit tests for MyOrdersPage states
    - Test loading, empty, error, and data states
    - _Requirements: 5.4, 5.5, 5.6_

- [ ] 6. Checkpoint — Ensure all data pages compile and tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Implement SettingsPage
  - [x] 7.1 Create `lib/screens/profile/settings_page.dart`
    - `StatefulWidget` using `_SubPageScaffold` with title "Settings"
    - Dark mode section: `ValueListenableBuilder` over `themeNotifier` from `main.dart`; `Switch` writes back to `themeNotifier.value`
    - Account info section: read-only `ListTile`s for displayName and email from `FirebaseAuth.instance.currentUser`
    - Change password section: shown only when `user.providerData` contains `password` provider; calls `FirebaseAuth.instance.sendPasswordResetEmail(email: email)` and shows a `SnackBar` on success or failure
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 7.1, 7.2_

  - [ ]* 7.2 Write unit tests for SettingsPage
    - Test dark mode toggle updates `themeNotifier`
    - Test change password button visibility for email vs. social providers
    - _Requirements: 6.1, 6.2, 6.4_

- [x] 8. Wire navigation in profile_page.dart
  - [x] 8.1 Add imports for all five sub-pages at the top of `lib/screens/profile/profile_page.dart`
  - [x] 8.2 Replace the five empty `() {}` callbacks in `_LoggedInProfileState.build()` with `Navigator.push(context, MaterialPageRoute(...))` calls as specified in the design
    - My Bookings → `MyBookingsPage`
    - Saved Salons → `SavedSalonsPage`
    - My Reviews → `MyReviewsPage`
    - My Orders → `MyOrdersPage`
    - Settings → `SettingsPage`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 9. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP
- All data pages follow the same `StreamBuilder` pattern — implement helpers first (task 1) before the data pages
- `themeNotifier` is declared in `lib/main.dart` and must be imported in `settings_page.dart`
- No new model classes are introduced; data is read directly from `QueryDocumentSnapshot` maps
