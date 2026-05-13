# 🚀 Fellow4u API Setup Guide - Complete Reference

## 📋 What You Have Now

You now have a complete API system with **35+ endpoints** designed for your Fellow4u Flutter app. Here's what was created:

### 📁 Files Created:

1. **`lib/services/api_service_v2.dart`** ⭐
   - Complete API service with all 35 endpoints implemented
   - Ready to integrate into your screens
   - Includes error handling & fallback data

2. **`API_DESIGN.md`**
   - Overview of all 35+ endpoints
   - Organized by feature category
   - Response format specifications

3. **`API_IMPLEMENTATION_GUIDE.md`**
   - Step-by-step implementation guide
   - Code examples for each of 10 main screens
   - Best practices for error handling

4. **`SCREEN_TO_API_MAPPING.md`**
   - Detailed mapping of APIs to screens
   - Which APIs each screen uses
   - Data flow diagrams

5. **`Fellow4u_API_Collection.postman_collection.json`**
   - Postman collection ready to import
   - Test all 35+ endpoints before integration
   - Includes sample request/response data

---

## ⚙️ Step 1: Configure Your Backend

Edit `lib/services/api_service_v2.dart` and set your base URL:

```dart
// Option 1: Using Requex.me
static const String baseUrl = "https://api.requex.me/api/v1";

// Option 2: Using MockAPI.io (Free option)
static const String baseUrl = "https://mockapi.io/api/v1";

// Option 3: Using Postman Mock Server
static const String baseUrl = "YOUR_POSTMAN_URL/api/v1";

// Option 4: Your custom backend
static const String baseUrl = "https://yourbackend.com/api/v1";
```

---

## 🧪 Step 2: Test APIs with Postman

### Import Collection:
1. Open Postman
2. Click "Import" 
3. Upload `Fellow4u_API_Collection.postman_collection.json`
4. Set the `baseUrl` variable in Postman to your backend URL
5. Test each endpoint

### Update Base URL in Postman:
```
In Postman:
  Variables Tab → baseUrl → Change to your URL
  Example: https://api.requex.me/api/v1
```

---

## 🎯 Step 3: Integrate into Your Screens

### Option A: Quick Start (Replace current api_service.dart)
```bash
# Backup your current file
cp lib/services/api_service.dart lib/services/api_service.backup.dart

# Copy new API service
cp lib/services/api_service_v2.dart lib/services/api_service.dart
```

### Option B: Keep Both Files
Keep both `api_service.dart` and `api_service_v2.dart`, then gradually migrate to the new one.

---

## 📱 Implementation Order (Recommended)

### Phase 1: Authentication
1. Update `lib/screens/login_screen.dart`
   - Use API #2: `loginUser()`
   - Reference: See `API_IMPLEMENTATION_GUIDE.md` → Section "1️⃣ Login Screen"

2. Update `lib/screens/register_screen.dart`
   - Use API #1: `registerUser()`
   - Reference: See `API_IMPLEMENTATION_GUIDE.md` → Section "2️⃣ Register Screen"

3. Update `lib/screens/forgot_password_screen.dart`
   - Use API #3: `forgotPassword()`
   - Use API #4: `verifyOtp()`
   - Use API #5: `resetPassword()`

### Phase 2: Main Features
4. Update `lib/screens/home_screen.dart`
   - Use API #11: `getTours()`
   - Use API #32: `getHomeFeed()`

5. Update `lib/screens/search_screen.dart`
   - Use API #13: `searchTours()`
   - Use API #35: `getTourCategories()`

6. Update `lib/screens/tour_detail_screen.dart`
   - Use API #12: `getTourDetail()`
   - Use API #33: `getTourReviews()`
   - Use API #30: `addToFavorites()`

### Phase 3: Bookings & Payments
7. Update `lib/screens/booking_screen.dart`
   - Use API #17: `createBooking()`

8. Update `lib/screens/payment_screen.dart`
   - Use API #20: `createPayment()`
   - Use API #21: `verifyPayment()`

### Phase 4: User Features
9. Update `lib/screens/my_trips_screen.dart`
   - Use API #16: `getBookings()`
   - Use API #18: `getBookingDetail()`
   - Use API #19: `cancelBooking()`

10. Update `lib/screens/chat_screen.dart`
    - Use API #26: `getConversations()`
    - Use API #27: `getMessages()`
    - Use API #28: `sendMessage()`

### Phase 5: Additional Features
11. Update `lib/screens/notifications_screen.dart`
    - Use API #23: `getNotifications()`
    - Use API #24: `markNotificationAsRead()`
    - Use API #25: `deleteNotification()`

12. Update `lib/screens/profile_screen.dart`
    - Use API #6: `getUserProfile()`
    - Use API #7: `updateUserProfile()`
    - Use API #8: `getUserSettings()`
    - Use API #9: `updateUserSettings()`

13. Update `lib/screens/favorite_screen.dart`
    - Use API #29: `getFavorites()`
    - Use API #31: `removeFromFavorites()`

---

## 💡 Code Example Template

Here's a template to use when updating each screen:

```dart
import 'package:fellow4u/services/api_service_v2.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late Future<dynamic> _dataFuture;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      _dataFuture = ApiService.getTours(); // Change this to your API call
      setState(() {});
    } catch (e) {
      print("Error loading data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Screen Title")),
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No data available"));
          }
          
          // Display your data here
          return Center(child: Text("Data loaded"));
        },
      ),
    );
  }
}
```

---

## 🌐 Choosing Your Backend Service

### Option 1: **Requex.me** ⭐ (Recommended)
- Modern mock API service
- Easy to set up
- Good for testing
- **URL:** `https://api.requex.me/api/v1`

### Option 2: **MockAPI.io**
- Free tier available
- Easy CRUD operations
- Good for prototyping
- **URL:** `https://mockapi.io/api/v1`

### Option 3: **Postman Mock Server**
- Integrated with Postman
- Professional option
- Good documentation
- **URL:** Your custom Postman mock URL

### Option 4: **Your Custom Backend**
- Full control
- Use Node.js, Laravel, Django, etc.
- Production-ready
- **URL:** Your backend URL

---

## 📊 API Usage Statistics

| Category | Count | Examples |
|----------|-------|----------|
| Authentication | 5 | Login, Register, Reset Password |
| User Profile | 5 | Get Profile, Update Profile, Settings |
| Tours | 5 | Get Tours, Search, Create |
| Bookings | 4 | Create Booking, Cancel, Get List |
| Payments | 3 | Create, Verify, History |
| Notifications | 3 | Get, Read, Delete |
| Chat | 3 | Conversations, Messages, Send |
| Favorites | 3 | Get, Add, Remove |
| Features | 5 | Feed, Reviews, Categories |
| **Total** | **36** | |

---

## 🔍 Common Issues & Solutions

### Issue #1: API 404 Not Found
**Solution:** Check if your backend has these endpoints. If using a mock service, you may need to create them first.

### Issue #2: CORS Errors
**Solution:** Ensure your backend has CORS headers enabled:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type
```

### Issue #3: Authentication Failures
**Solution:** Check if your login endpoint returns the correct user data. Store the token:
```dart
// After successful login
SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setString('authToken', result['token']);
```

### Issue #4: Timeout Errors
**Solution:** Increase timeout duration:
```dart
.timeout(const Duration(seconds: 15)) // Increase from 10 to 15
```

---

## ✅ Testing Checklist

- [ ] All endpoints work in Postman
- [ ] Backend is configured in `api_service_v2.dart`
- [ ] Login/Register works
- [ ] Can fetch tours on Home screen
- [ ] Can search tours
- [ ] Can view tour details & reviews
- [ ] Can create a booking
- [ ] Can make a payment
- [ ] Can view my trips
- [ ] Can send chat messages
- [ ] Can view notifications
- [ ] Can add/remove favorites
- [ ] Error handling works properly
- [ ] Loading states display correctly
- [ ] App handles network errors gracefully

---

## 🚀 Deployment Tips

### Before Deploying:
1. Switch to your production backend URL
2. Add authentication tokens to requests:
```dart
headers: {
  "Content-Type": "application/json",
  "Authorization": "Bearer YOUR_TOKEN",
}
```

3. Add request timeout handling
4. Implement proper error logging
5. Add analytics tracking
6. Test on real devices

---

## 📞 Support & Documentation

- **Requex.me Docs:** https://requex.me/docs
- **MockAPI.io Docs:** https://mockapi.io/
- **Postman Docs:** https://learning.postman.com/
- **Flutter HTTP:** https://pub.dev/packages/http

---

## 🎓 Next Steps

1. ✅ **Read:** `API_DESIGN.md` - Understand the overall structure
2. ✅ **Setup:** Configure your backend URL
3. ✅ **Test:** Import Postman collection and test endpoints
4. ✅ **Implement:** Follow `API_IMPLEMENTATION_GUIDE.md`
5. ✅ **Reference:** Use `SCREEN_TO_API_MAPPING.md` as you code
6. ✅ **Deploy:** Connect to production backend

---

## 💬 Summary

You now have:
- ✅ **35+ fully documented APIs**
- ✅ **Complete Dart service implementation**
- ✅ **Postman collection for testing**
- ✅ **Implementation guides with code examples**
- ✅ **Screen-to-API mapping documentation**

**Next:** Pick your backend service and start integrating! 🎉

---

**Questions?** Refer to the individual documentation files:
- API Design Details → `API_DESIGN.md`
- Code Implementation Examples → `API_IMPLEMENTATION_GUIDE.md`
- Which APIs to use for each screen → `SCREEN_TO_API_MAPPING.md`
