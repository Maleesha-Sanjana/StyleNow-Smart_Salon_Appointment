# Requirements Document

## Introduction

This feature implements five profile sub-pages for the StyleNow Flutter app, accessible from the Profile tab for logged-in users: My Bookings, Saved Salons, My Reviews, My Orders, and Settings. Each page is navigated to from the profile menu tiles and displays user-specific data fetched from Firebase Firestore. Guest users see locked tiles that redirect to the login sheet.

## Glossary

- **Profile_Page**: The main profile screen accessible via the Profile tab in the bottom navigation bar.
- **My_Bookings_Page**: Sub-page displaying the authenticated user's past and upcoming salon appointments.
- **Saved_Salons_Page**: Sub-page displaying salons the authenticated user has saved/favorited.
- **My_Reviews_Page**: Sub-page displaying reviews the authenticated user has written for salons.
- **My_Orders_Page**: Sub-page displaying beauty product orders placed by the authenticated user.
- **Settings_Page**: Sub-page allowing the authenticated user to manage app preferences and account settings.
- **Booking**: A salon appointment record stored in Firestore under the `bookings` collection, associated with a user UID.
- **Saved_Salon**: A Firestore document in the `saved_salons` sub-collection under a user's document, referencing a salon.
- **Review**: A Firestore document in the `reviews` collection containing a rating, comment, salon reference, and user UID.
- **Order**: A Firestore document in the `orders` collection representing a marketplace product purchase by a user.
- **Auth_Guard**: The existing `guardAction` function in `auth_state.dart` that blocks guest access and shows a login prompt.
- **Firestore**: Firebase Cloud Firestore used as the primary database backend.
- **Firebase_Auth**: Firebase Authentication service used to identify the current user.

---

## Requirements

### Requirement 1: Navigation from Profile Page to Sub-Pages

**User Story:** As a logged-in user, I want to tap a menu tile on my profile page and navigate to the corresponding sub-page, so that I can access my bookings, saved salons, reviews, orders, and settings.

#### Acceptance Criteria

1. WHEN a logged-in user taps the "My Bookings" tile on the Profile_Page, THE Profile_Page SHALL navigate to the My_Bookings_Page.
2. WHEN a logged-in user taps the "Saved Salons" tile on the Profile_Page, THE Profile_Page SHALL navigate to the Saved_Salons_Page.
3. WHEN a logged-in user taps the "My Reviews" tile on the Profile_Page, THE Profile_Page SHALL navigate to the My_Reviews_Page.
4. WHEN a logged-in user taps the "My Orders" tile on the Profile_Page, THE Profile_Page SHALL navigate to the My_Orders_Page.
5. WHEN a logged-in user taps the "Settings" tile on the Profile_Page, THE Profile_Page SHALL navigate to the Settings_Page.
6. WHEN a guest user taps any profile menu tile, THE Auth_Guard SHALL display the login sheet instead of navigating to the sub-page.

---

### Requirement 2: My Bookings Page

**User Story:** As a logged-in user, I want to view all my salon appointments in one place, so that I can track upcoming and past bookings.

#### Acceptance Criteria

1. THE My_Bookings_Page SHALL display a list of Booking records associated with the current user's UID, fetched from Firestore.
2. WHEN the My_Bookings_Page loads, THE My_Bookings_Page SHALL query Firestore for documents in the `bookings` collection where the `userId` field equals the current user's UID.
3. WHEN a Booking record exists, THE My_Bookings_Page SHALL display the salon name, service name, appointment date, appointment time, and booking status for each record.
4. WHEN no Booking records exist for the current user, THE My_Bookings_Page SHALL display an empty state message indicating no bookings have been made.
5. WHILE Booking records are being fetched from Firestore, THE My_Bookings_Page SHALL display a loading indicator.
6. IF a Firestore read error occurs, THEN THE My_Bookings_Page SHALL display an error message to the user.
7. WHEN a user taps the back button on the My_Bookings_Page, THE My_Bookings_Page SHALL navigate back to the Profile_Page.

---

### Requirement 3: Saved Salons Page

**User Story:** As a logged-in user, I want to view all the salons I have saved, so that I can quickly access my favorite salons.

#### Acceptance Criteria

1. THE Saved_Salons_Page SHALL display a list of salons saved by the current user, fetched from Firestore.
2. WHEN the Saved_Salons_Page loads, THE Saved_Salons_Page SHALL query Firestore for documents in the `saved_salons` collection where the `userId` field equals the current user's UID.
3. WHEN a Saved_Salon record exists, THE Saved_Salons_Page SHALL display the salon name, salon image, and salon rating for each saved salon.
4. WHEN no Saved_Salon records exist for the current user, THE Saved_Salons_Page SHALL display an empty state message indicating no salons have been saved.
5. WHILE Saved_Salon records are being fetched from Firestore, THE Saved_Salons_Page SHALL display a loading indicator.
6. IF a Firestore read error occurs, THEN THE Saved_Salons_Page SHALL display an error message to the user.
7. WHEN a user taps the back button on the Saved_Salons_Page, THE Saved_Salons_Page SHALL navigate back to the Profile_Page.

---

### Requirement 4: My Reviews Page

**User Story:** As a logged-in user, I want to view all the reviews I have written, so that I can see my feedback history for salons.

#### Acceptance Criteria

1. THE My_Reviews_Page SHALL display a list of Review records authored by the current user, fetched from Firestore.
2. WHEN the My_Reviews_Page loads, THE My_Reviews_Page SHALL query Firestore for documents in the `reviews` collection where the `userId` field equals the current user's UID.
3. WHEN a Review record exists, THE My_Reviews_Page SHALL display the salon name, star rating, review comment, and review date for each record.
4. WHEN no Review records exist for the current user, THE My_Reviews_Page SHALL display an empty state message indicating no reviews have been written.
5. WHILE Review records are being fetched from Firestore, THE My_Reviews_Page SHALL display a loading indicator.
6. IF a Firestore read error occurs, THEN THE My_Reviews_Page SHALL display an error message to the user.
7. WHEN a user taps the back button on the My_Reviews_Page, THE My_Reviews_Page SHALL navigate back to the Profile_Page.

---

### Requirement 5: My Orders Page

**User Story:** As a logged-in user, I want to view all my marketplace product orders, so that I can track my purchase history.

#### Acceptance Criteria

1. THE My_Orders_Page SHALL display a list of Order records associated with the current user's UID, fetched from Firestore.
2. WHEN the My_Orders_Page loads, THE My_Orders_Page SHALL query Firestore for documents in the `orders` collection where the `userId` field equals the current user's UID.
3. WHEN an Order record exists, THE My_Orders_Page SHALL display the product name, order date, order total amount, and order status for each record.
4. WHEN no Order records exist for the current user, THE My_Orders_Page SHALL display an empty state message indicating no orders have been placed.
5. WHILE Order records are being fetched from Firestore, THE My_Orders_Page SHALL display a loading indicator.
6. IF a Firestore read error occurs, THEN THE My_Orders_Page SHALL display an error message to the user.
7. WHEN a user taps the back button on the My_Orders_Page, THE My_Orders_Page SHALL navigate back to the Profile_Page.

---

### Requirement 6: Settings Page

**User Story:** As a logged-in user, I want to manage my app preferences and account settings, so that I can personalise my experience and control my account.

#### Acceptance Criteria

1. THE Settings_Page SHALL display a dark mode toggle that switches the app between light and dark themes.
2. WHEN a user toggles the dark mode switch, THE Settings_Page SHALL update the global `themeNotifier` ValueNotifier to reflect the selected ThemeMode.
3. THE Settings_Page SHALL display the current user's display name and email address as read-only account information.
4. THE Settings_Page SHALL display a "Change Password" option for users authenticated via email and password.
5. WHEN a user taps "Change Password", THE Settings_Page SHALL send a password reset email to the current user's email address via Firebase_Auth.
6. WHEN the password reset email is sent successfully, THE Settings_Page SHALL display a confirmation message to the user.
7. IF the password reset email fails to send, THEN THE Settings_Page SHALL display an error message to the user.
8. WHEN a user taps the back button on the Settings_Page, THE Settings_Page SHALL navigate back to the Profile_Page.

---

### Requirement 7: Consistent Page Structure

**User Story:** As a user, I want all profile sub-pages to have a consistent visual style, so that the app feels cohesive and professional.

#### Acceptance Criteria

1. THE My_Bookings_Page, Saved_Salons_Page, My_Reviews_Page, My_Orders_Page, and Settings_Page SHALL each display an AppBar with a back navigation button and a page title.
2. THE My_Bookings_Page, Saved_Salons_Page, My_Reviews_Page, My_Orders_Page, and Settings_Page SHALL use the app's existing theme colours defined in `AppTheme` and `AppColors`.
3. THE My_Bookings_Page, Saved_Salons_Page, My_Reviews_Page, and My_Orders_Page SHALL display data in a scrollable list of cards consistent with the existing card style used in the Profile_Page.
