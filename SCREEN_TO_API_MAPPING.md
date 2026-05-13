# Fellow4u - Screen to API Mapping

## Overview
This document maps all 35+ APIs to the 10 main screens and shows which APIs each screen uses.

---

## 📱 10 Main Screens & APIs

### **1. Login Screen** (`lib/screens/login_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 2 | POST `/auth/login` | loginUser() | Authenticate user with email/password |
| 3 | POST `/auth/forgot-password` | forgotPassword() | Handle "Forgot Password" link |

**Flow:**
```
User enters email & password 
    ↓
Call API #2: loginUser()
    ↓
If success → Store token, Navigate to Home
    ↓
If "Forgot Password" clicked → Call API #3
    ↓
Navigate to forgot_password_screen
```

---

### **2. Register Screen** (`lib/screens/register_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 1 | POST `/auth/register` | registerUser() | Create new user account |

**Flow:**
```
User fills: Name, Email, Password, Phone
    ↓
Call API #1: registerUser()
    ↓
If success → Show success message, Navigate to Login
    ↓
If error → Show error message
```

---

### **3. Home Screen** (`lib/screens/home_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 11 | GET `/tours?page=1&limit=10` | getTours() | Fetch featured tours/trips |
| 32 | GET `/home/feed` | getHomeFeed() | Get home page feed (banners, promotions) |

**Flow:**
```
Home Screen loads
    ↓
Call API #11: getTours() [Featured/Popular]
Call API #32: getHomeFeed() [Banners, Promotions]
    ↓
Display tours in grid/list
Display feed at top
    ↓
User taps on tour → Navigate to Tour Detail Screen
```

---

### **4. Search Screen** (`lib/screens/search_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 11 | GET `/tours?search=...` | getTours() | Get tours with search filter |
| 13 | GET `/tours/search?q=...` | searchTours() | Advanced search with filters |
| 35 | GET `/categories` | getTourCategories() | Get tour categories for filters |

**Flow:**
```
User enters search query
    ↓
Call API #13: searchTours(query, location, price range)
    ↓
Display filtered results
    ↓
User can filter by:
  - Category (API #35)
  - Price range
  - Location
```

---

### **5. Tour Detail Screen** (`lib/screens/tour_detail_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 12 | GET `/tours/:id` | getTourDetail() | Get full tour details |
| 33 | GET `/reviews?tourId=:id` | getTourReviews() | Get tour reviews & ratings |
| 30 | POST `/favorites` | addToFavorites() | Add tour to favorites |
| 31 | DELETE `/favorites/:id` | removeFromFavorites() | Remove from favorites |

**Flow:**
```
Tour Detail page loads
    ↓
Call API #12: getTourDetail(tourId)
Call API #33: getTourReviews(tourId)
    ↓
Display: Title, Description, Images, Reviews
    ↓
User can:
  - Add to Favorites (API #30)
  - Remove from Favorites (API #31)
  - Click "Book Now" → Booking Screen
```

---

### **6. Booking Screen** (`lib/screens/booking_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 17 | POST `/bookings` | createBooking() | Create new booking |

**Flow:**
```
User selects: Date, Number of Persons, Special requests
    ↓
Call API #17: createBooking()
    ↓
If success:
  - Get booking ID
  - Navigate to Payment Screen with booking data
    ↓
If error → Show error message
```

---

### **7. My Trips Screen** (`lib/screens/my_trips_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 16 | GET `/bookings?userId=:id` | getBookings() | Get user's all bookings |
| 18 | GET `/bookings/:id` | getBookingDetail() | Get specific booking details |
| 19 | DELETE `/bookings/:id` | cancelBooking() | Cancel a booking |

**Flow:**
```
My Trips page loads
    ↓
Call API #16: getBookings(userId)
    ↓
Display list of bookings:
  - Upcoming trips
  - Past trips
  - Cancelled trips
    ↓
User can:
  - Tap to view details (API #18)
  - Cancel booking (API #19)
  - Message guide (Chat Screen)
```

---

### **8. Chat Screen** (`lib/screens/chat_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 26 | GET `/conversations?userId=:id` | getConversations() | Get user's conversations |
| 27 | GET `/messages?conversationId=:id` | getMessages() | Get messages in a conversation |
| 28 | POST `/messages` | sendMessage() | Send a new message |

**Flow:**
```
Chat page loads
    ↓
Call API #26: getConversations(userId)
    ↓
Display conversations list
    ↓
User taps on conversation
    ↓
Call API #27: getMessages(conversationId)
    ↓
User types message
    ↓
Call API #28: sendMessage()
    ↓
Message appears in chat
```

---

### **9. Notifications Screen** (`lib/screens/notifications_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 23 | GET `/notifications?userId=:id` | getNotifications() | Get user's notifications |
| 24 | POST `/notifications/:id/read` | markNotificationAsRead() | Mark notification as read |
| 25 | DELETE `/notifications/:id` | deleteNotification() | Delete notification |

**Flow:**
```
Notifications page loads
    ↓
Call API #23: getNotifications(userId)
    ↓
Display notifications:
  - Booking confirmations
  - Reviews
  - Chat messages
  - Promotions
    ↓
User can:
  - Tap to read (API #24)
  - Swipe to delete (API #25)
```

---

### **10. Payment Screen** (`lib/screens/payment_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 20 | POST `/payments` | createPayment() | Create payment transaction |
| 21 | POST `/payments/:id/verify` | verifyPayment() | Verify payment status |
| 22 | GET `/payments/history?userId=:id` | getPaymentHistory() | Get user's payment history |

**Flow:**
```
Payment screen loads with booking data
    ↓
Call API #20: createPayment(bookingId, amount, method)
    ↓
Show payment methods:
  - Credit Card
  - Bank Transfer
  - Wallet
    ↓
User selects payment method & confirms
    ↓
Call API #21: verifyPayment()
    ↓
If verified:
  - Update booking status to confirmed
  - Show success
  - Navigate to Home
    ↓
User can view history: API #22
```

---

## 📊 Additional Features (Used by Multiple Screens)

### **Profile Screen** (`lib/screens/profile_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 6 | GET `/users/:id` | getUserProfile() | Get user profile data |
| 7 | PUT `/users/:id` | updateUserProfile() | Update user info |
| 8 | GET `/users/:id/settings` | getUserSettings() | Get notification settings |
| 9 | PUT `/users/:id/settings` | updateUserSettings() | Update settings |
| 10 | DELETE `/users/:id` | deleteUserAccount() | Delete account |

---

### **Favorite Screen** (`lib/screens/favorite_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 29 | GET `/favorites?userId=:id` | getFavorites() | Get favorite tours |
| 31 | DELETE `/favorites/:id` | removeFromFavorites() | Remove from favorites |

---

### **Create Trip Screen** (`lib/screens/create_trip_screen.dart`)
| API # | Endpoint | Method | Purpose |
|-------|----------|--------|---------|
| 14 | POST `/tours` | createTour() | Create new tour/trip |
| 15 | PUT `/tours/:id` | updateTour() | Update tour details |

---

## 🔄 API Call Summary

| Screen | API Calls | Total |
|--------|-----------|-------|
| Login | 2, 3 | 2 |
| Register | 1 | 1 |
| Home | 11, 32 | 2 |
| Search | 11, 13, 35 | 3 |
| Tour Detail | 12, 33, 30, 31 | 4 |
| Booking | 17 | 1 |
| My Trips | 16, 18, 19 | 3 |
| Chat | 26, 27, 28 | 3 |
| Notifications | 23, 24, 25 | 3 |
| Payment | 20, 21, 22 | 3 |
| **Total Unique APIs Used** | | **28** |

---

## 🎯 Quick Reference - All 35 APIs

```
AUTHENTICATION (5 APIs)
#1 POST /auth/register
#2 POST /auth/login
#3 POST /auth/forgot-password
#4 POST /auth/verify-otp
#5 POST /auth/reset-password

USER PROFILE (5 APIs)
#6 GET /users/:id
#7 PUT /users/:id
#8 GET /users/:id/settings
#9 PUT /users/:id/settings
#10 DELETE /users/:id

TOURS (5 APIs)
#11 GET /tours
#12 GET /tours/:id
#13 GET /tours/search
#14 POST /tours
#15 PUT /tours/:id

BOOKINGS (4 APIs)
#16 GET /bookings
#17 POST /bookings
#18 GET /bookings/:id
#19 DELETE /bookings/:id

PAYMENTS (3 APIs)
#20 POST /payments
#21 POST /payments/:id/verify
#22 GET /payments/history

NOTIFICATIONS (3 APIs)
#23 GET /notifications
#24 POST /notifications/:id/read
#25 DELETE /notifications/:id

MESSAGING (3 APIs)
#26 GET /conversations
#27 GET /messages
#28 POST /messages

FAVORITES (3 APIs)
#29 GET /favorites
#30 POST /favorites
#31 DELETE /favorites/:id

ADDITIONAL (5 APIs)
#32 GET /home/feed
#33 GET /reviews
#34 POST /reviews
#35 GET /categories
```

---

## 📝 Implementation Checklist

- [ ] Configure `baseUrl` in `api_service_v2.dart`
- [ ] Test each API in Postman (use provided collection)
- [ ] Implement Login Screen (APIs #2, #3)
- [ ] Implement Register Screen (API #1)
- [ ] Implement Home Screen (APIs #11, #32)
- [ ] Implement Search Screen (APIs #11, #13, #35)
- [ ] Implement Tour Detail Screen (APIs #12, #33, #30, #31)
- [ ] Implement Booking Screen (API #17)
- [ ] Implement My Trips Screen (APIs #16, #18, #19)
- [ ] Implement Chat Screen (APIs #26, #27, #28)
- [ ] Implement Notifications Screen (APIs #23, #24, #25)
- [ ] Implement Payment Screen (APIs #20, #21, #22)
- [ ] Implement Profile Screen (APIs #6, #7, #8, #9, #10)
- [ ] Implement Favorites Screen (APIs #29, #31)
- [ ] Add error handling & loading states
- [ ] Test full app flow
- [ ] Deploy to backend

---

## 🚀 Getting Started

1. **Choose your backend service:**
   - Requex.me (if using this service)
   - MockAPI.io (free option)
   - Postman Mock Server
   - Your custom backend

2. **Update the base URL in `api_service_v2.dart`**

3. **Import Postman collection:** `Fellow4u_API_Collection.postman_collection.json`

4. **Test each API before integration**

5. **Implement screens one by one**

6. **Test the full app flow**

Good luck! 🎉
