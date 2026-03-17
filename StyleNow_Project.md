# 💇 StyleNow - Smart Salon Appointment & Beauty Service Booking App

## 📱 Project Overview

StyleNow is a mobile application that allows users to easily discover salons, explore services, and book appointments instantly. The app connects customers with nearby salons and enables them to schedule grooming and beauty services quickly.

The platform supports both guest users and registered users, allowing people to explore salons before signing up.

---

## 1️⃣ Guest User Mode

When a user first opens the app:

**Users can view:**
- Home feed (hair care tips, beauty posts, promotions)
- Featured salons
- Popular hairstyles
- Salon service list
- Beauty products marketplace
- Customer reviews

**Users cannot interact:**
- Booking salon appointments
- Liking or commenting on posts
- Saving favorite salons
- Managing personal profile
- Viewing nearby salons using GPS
- Adding reviews

**UI Behavior**
If a guest presses restricted buttons like Book Appointment, Like, Write Review, Save Salon:
> Show popup: "Login to access this feature"

---

## 2️⃣ Registered / Logged-In User Mode

After user login or signup, full features are unlocked.

**Users can:**
- Book salon appointments
- View nearby salons using GPS
- Save favorite salons
- Write reviews
- Like and comment on beauty posts
- Manage personal profile
- View booking history
- Purchase beauty products

**UI Behavior:**
- Bottom navigation remains
- Feed becomes interactive
- Profile tab unlocked
- Nearby salons appear on map

---

## 3️⃣ Login Options (Modern App Style)

- Email + Password
- Phone Number OTP
- Google Login
- Apple Login
- Optional: Continue as guest (session converts to full account later)

---

## 4️⃣ Facebook-Style Navigation Structure

### 🏠 Home Feed
- Guest: Scroll beauty tips, view salon promotions
- Logged-in: Like, Comment, Share, Save posts

### 📰 Feed Section (replaces Services in nav bar)
- Facebook-style social feed for the beauty/salon community
- Guest: Scroll and view posts only
- Logged-in: Like, Comment, Share posts, Create new posts (photo/video)

**Post interactions:**
- Like button (heart) — toggles liked state, shows like count
- Comment button — expands inline comment thread with reply input
- Share button — share post (requires login)
- Create Post button (top-right) — opens bottom sheet with text + Photo/Video selector

**Guest restrictions:**
- Like, Comment, Share, Create Post → shows "Login to access this feature" popup

### 📍 Salons Section
- Guest: View salon list
- Logged-in: Find nearest salons, view distance, book appointments, see ratings

### 🛍 Marketplace
- Guest: Browse beauty products
- Logged-in: Add to cart, purchase, save products

### 👤 Profile Section
- Guest: Shows "Login to unlock features"
- Logged-in: Personal details, booking history, favorite salons, saved services, orders

---

## 5️⃣ Backend Logic (Guest vs Logged User)

| Feature               | Guest | Logged-in |
|-----------------------|-------|-----------|
| View Home Feed        | ✅    | ✅        |
| View Salon List       | ✅    | ✅        |
| Book Appointment      | ❌    | ✅        |
| Like / Comment        | ❌    | ✅        |
| Save Salon            | ❌    | ✅        |
| Write Reviews         | ❌    | ✅        |
| Purchase Products     | ❌    | ✅        |
| View Nearest Salons   | ❌    | ✅        |

---

## 6️⃣ Technology Stack

### 📱 Frontend — Flutter
- `BottomNavigationBar` + `PageView` navigation
- Login modal dialogs
- Card-based feed (Facebook style)

**Libraries:**
- `provider` / `riverpod` — state management
- `google_maps_flutter`
- `geolocator`
- `firebase_auth`

### ⚙️ Backend — Firebase
- **Authentication:** Anonymous login (guest) → Email / Google / Phone (registered)
- **Cloud Functions:** Nearest salons, appointment slot management, booking confirmations
- **Database:** Firestore

---

## 7️⃣ UI Design Notes (Facebook Style)

- Feed: Scrollable cards, salon promotions, beauty tips
- Navigation: Bottom nav — Home, Feed, Salons, Marketplace, Profile
- Guest Mode: Book, Like, Comment, Save buttons disabled → popup on tap

---

## 8️⃣ Example User Flow

1. User opens app
2. Sees trending hairstyles and salons
3. User taps "Book Haircut"
4. Popup: "Login to book appointments"
5. User logs in
6. User selects: Salon → Service → Stylist → Date → Time
7. Appointment confirmed ✅

---

## 💇 StyleNow – Extended Platform Roles

### 1️⃣ Customers (Salon Clients)
People who want salon or beauty services.

**Features:**
- Book salon appointments
- Find nearby salons
- View services and prices
- Rate salons and stylists
- Save favorite salons
- View beauty tips and posts

---

### 2️⃣ Salon Owners / Stylists
Businesses providing salon services.

**Features:**
- Create salon profile
- Add services and prices
- Manage bookings
- Post job vacancies
- Purchase salon products from suppliers
- Connect with beautician doctors

---

### 🩺 3️⃣ Beautician Doctors (Health Support)

Sometimes beauticians develop problems like:
- Skin allergies from chemicals
- Hair dye reactions
- Nail technician infections
- Respiratory problems from sprays

**Doctor Role Features:**
- Provide online consultations
- Give treatment advice
- Post health tips for beauticians
- Offer video consultations (optional future feature)

**Example Use Case:**
Beautician develops skin allergy from hair dye → Opens Health Support in StyleNow → Books consultation with dermatologist → Doctor gives treatment advice

---

### 💼 4️⃣ Salon Job Marketplace

**Salon Owners can post:**
- Hair stylist jobs
- Makeup artist jobs
- Barber jobs
- Nail technician jobs
- Receptionist jobs

**Job Seekers can:**
- Search jobs
- Apply for positions
- Upload portfolio
- Contact salons

---

### 🧴 5️⃣ Salon Product Suppliers

**Examples of supplies:**
- Hair dye, shampoo, hair treatment products
- Nail tools, salon chairs, hair dryers

**Supplier Role:**
- Create product catalog
- Sell salon equipment
- Deliver products to salons

**Salon Owners can:**
- Browse suppliers
- Order salon products
- Compare prices

---

### 👨‍💻 6️⃣ System Admin

**Responsibilities:**
- Approve salons
- Approve doctors
- Manage suppliers
- Moderate posts
- Monitor bookings
- Manage job listings


---

## 📱 Landing Page (Home Screen)

This is the first screen users see when they open the app.

---

### 1️⃣ Top Header (Location + Profile)

```
📍 Colombo, Sri Lanka          🔔  👤
```

- 📍 Current location (auto-detected via GPS)
- 👤 Profile icon
- 🔔 Notifications

---

### 2️⃣ Big Search Bar

```
🔎 Search salons, services, or stylists...
```

Users can search by:
- Salon name
- Service (Haircut, Beard trimming, Facial, Hair coloring)

---

### 3️⃣ Quick Service Categories

Horizontal scrollable chips for quick access:

| Icon | Category    |
|------|-------------|
| ✂️   | Haircut     |
| 🧔   | Beard Trim  |
| 💄   | Makeup      |
| 💆   | Facial      |
| 💅   | Nails       |
| 🎨   | Hair Color  |

Tap a category → instantly see salons offering that service.

---

### 4️⃣ Nearby Salons Section

Each salon card shows:

```
[ Salon Image ]
Golden Scissors Salon
⭐ 4.7   📍 1.2 km away
Haircut starting from Rs. 1200
[ Book Now ]
```

- Salon image
- Name
- ⭐ Rating
- 📍 Distance
- 💰 Starting price
- Book Now button

---

### 5️⃣ Trending / Popular Salons

Section: **⭐ Popular Salons Near You**

- Horizontally scrollable salon cards
- Highlights top-rated salons

---

### 6️⃣ Beauty Tips / Community Posts (Optional)

Small feed at the bottom showing:
- Haircare tips
- Beauty trends
- Style inspiration

Adds social media-style engagement.

---

### 📐 Full Landing Page Layout

```
------------------------------------------------
 📍 Colombo, Sri Lanka          🔔   👤

 🔎 Search salons, services...

 [ ✂️ Haircut ] [ 🧔 Beard ] [ 💆 Facial ] [ 💅 Nails ]

 ⭐ Popular Salons
 [ Salon Card ] [ Salon Card ] [ Salon Card ] →

 📍 Nearby Salons
 [ Salon Card ]
 [ Salon Card ]
 [ Salon Card ]

 💡 Beauty Tips
 [ Post ] [ Post ]
------------------------------------------------
```
