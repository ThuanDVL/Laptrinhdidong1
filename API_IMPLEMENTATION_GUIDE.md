# Fellow4u API Implementation Guide

## Quick Start

### Step 1: Configure Your Backend URL
Edit `lib/services/api_service_v2.dart` and set your base URL:

```dart
// Option 1: Using Requex.me
static const String baseUrl = "https://api.requex.me/api/v1";

// Option 2: Using MockAPI.io
static const String baseUrl = "https://mockapi.io/api/v1";

// Option 3: Using Postman Mock Server
static const String baseUrl = "YOUR_POSTMAN_MOCK_URL/api/v1";
```

---

## 10 Main Screens & Their APIs

### **1️⃣ Login Screen** (`login_screen.dart`)
**API Used:** API #2 - loginUser()

```dart
import 'package:fellow4u/services/api_service_v2.dart';

// Example Usage:
final result = await ApiService.loginUser(
  email: emailController.text,
  password: passwordController.text,
);

if (result != null) {
  // Login successful
  Navigator.pushReplacementNamed(context, '/home');
} else {
  // Show error
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Login failed")),
  );
}
```

---

### **2️⃣ Register Screen** (`register_screen.dart`)
**APIs Used:** API #1 - registerUser()

```dart
// Example Usage:
final success = await ApiService.registerUser(
  name: nameController.text,
  email: emailController.text,
  password: passwordController.text,
  phone: phoneController.text,
);

if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Registration successful")),
  );
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

### **3️⃣ Home Screen** (`home_screen.dart`)
**APIs Used:** API #11 - getTours() & API #32 - getHomeFeed()

```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Tour>> _toursFuture;

  @override
  void initState() {
    super.initState();
    _toursFuture = ApiService.getTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: FutureBuilder<List<Tour>>(
        future: _toursFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tours available"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tour = snapshot.data![index];
              return ListTile(
                title: Text(tour.title),
                subtitle: Text(tour.location),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

### **4️⃣ Search Screen** (`search_screen.dart`)
**APIs Used:** API #13 - searchTours()

```dart
// Example Usage:
final results = await ApiService.searchTours(
  query: "Hà Nội",
  location: "Hà Nội",
  minPrice: 1000000,
  maxPrice: 5000000,
);

// Update UI with results
setState(() {
  searchResults = results;
});
```

---

### **5️⃣ Tour Detail Screen** (`tour_detail_screen.dart`)
**APIs Used:** API #12 - getTourDetail() & API #33 - getTourReviews()

```dart
class TourDetailScreen extends StatefulWidget {
  final String tourId;
  const TourDetailScreen({required this.tourId});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  late Future<Tour?> _tourFuture;
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _tourFuture = ApiService.getTourDetail(widget.tourId);
    _reviewsFuture = ApiService.getTourReviews(widget.tourId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tour Details")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tour Details
            FutureBuilder<Tour?>(
              future: _tourFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final tour = snapshot.data!;
                  return Column(
                    children: [
                      Image.network(tour.image),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tour.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(tour.location),
                            Text("${tour.price} VND"),
                            Text("Rating: ${tour.rating}"),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            // Reviews
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final review = snapshot.data![index];
                      return ListTile(
                        title: Text(review['userName']),
                        subtitle: Text(review['comment']),
                        trailing: Text("${review['rating']}⭐"),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### **6️⃣ Booking Screen** (`booking_screen.dart`)
**APIs Used:** API #17 - createBooking()

```dart
// Example Usage:
final bookingResult = await ApiService.createBooking(
  userId: currentUserId,
  tourId: tourId,
  numberOfPersons: int.parse(personsController.text),
  bookingDate: selectedDate.toString(),
);

if (bookingResult != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Booking successful")),
  );
  // Navigate to payment
  Navigator.pushNamed(context, '/payment', arguments: bookingResult);
}
```

---

### **7️⃣ My Trips Screen** (`my_trips_screen.dart`)
**APIs Used:** API #16 - getBookings()

```dart
class MyTripsScreen extends StatefulWidget {
  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = ApiService.getBookings(userId: currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Trips")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(booking['tourTitle']),
                  subtitle: Text("Status: ${booking['status']}"),
                  trailing: Text("${booking['numberOfPersons']} persons"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

### **8️⃣ Chat Screen** (`chat_screen.dart`)
**APIs Used:** API #26, #27, #28 - Conversation & Messaging APIs

```dart
class ChatScreen extends StatefulWidget {
  final String conversationId;
  const ChatScreen({required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  Future<void> _sendMessage() async {
    if (messageController.text.isNotEmpty) {
      final success = await ApiService.sendMessage(
        conversationId: widget.conversationId,
        senderId: currentUserId,
        message: messageController.text,
      );

      if (success) {
        messageController.clear();
        setState(() {}); // Refresh messages
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.getMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final msg = snapshot.data![index];
                      return ListTile(
                        title: Text(msg['message']),
                        subtitle: Text(msg['senderName']),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(hintText: "Type message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### **9️⃣ Notifications Screen** (`notifications_screen.dart`)
**APIs Used:** API #23, #24, #25 - Notification APIs

```dart
class NotificationsScreen extends StatefulWidget {
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = ApiService.getNotifications(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final notif = snapshot.data![index];
                return ListTile(
                  title: Text(notif['title']),
                  subtitle: Text(notif['message']),
                  onTap: () => ApiService.markNotificationAsRead(notif['id']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => ApiService.deleteNotification(notif['id']),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

---

### **🔟 Payment Screen** (`payment_screen.dart`)
**APIs Used:** API #20, #21 - Payment APIs

```dart
class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  const PaymentScreen({required this.bookingData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = "credit_card";

  Future<void> _processPayment() async {
    final paymentResult = await ApiService.createPayment(
      bookingId: bookingData['id'],
      amount: bookingData['totalPrice'],
      paymentMethod: selectedMethod,
    );

    if (paymentResult != null) {
      // Verify payment
      final verified = await ApiService.verifyPayment(paymentResult['id']);
      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment successful")),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Total: ${bookingData['totalPrice']} VND", 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            DropdownButton<String>(
              value: selectedMethod,
              items: const [
                DropdownMenuItem(value: "credit_card", child: Text("Credit Card")),
                DropdownMenuItem(value: "bank_transfer", child: Text("Bank Transfer")),
                DropdownMenuItem(value: "wallet", child: Text("Wallet")),
              ],
              onChanged: (value) => setState(() => selectedMethod = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _processPayment,
              child: const Text("Pay Now"),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Additional Helpful APIs

- **Favorites Screen**: Use API #29, #30, #31
- **Profile Screen**: Use API #6, #7, #8, #9
- **Settings Screen**: Use API #8, #9
- **Create Trip Screen**: Use API #14

---

## Error Handling Best Practice

```dart
try {
  final data = await ApiService.getTours();
  setState(() => tours = data);
} catch (e) {
  print("Error: $e");
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Error: ${e.toString()}")),
  );
}
```

---

## Testing Your APIs

Use tools like:
- **Postman** - https://www.postman.com/
- **Requex.me** - Your backend service
- **MockAPI.io** - Free mock API service
- **Thunder Client** (VS Code extension)

---

## Next Steps

1. ✅ Choose your backend service (Requex.me / MockAPI / Postman)
2. ✅ Update the `baseUrl` in `api_service_v2.dart`
3. ✅ Test each endpoint with Postman
4. ✅ Integrate APIs into each screen
5. ✅ Handle loading & error states
6. ✅ Test the full app flow
