import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tour.dart';
import '../models/user.dart';

/// ============================================================
/// FELLOW4U — ApiService
/// Kiến trúc: MockAPI.io free tier (2 resource)
///
///   /users → Đăng ký, Đăng nhập, Hồ sơ
///   /data  → Tất cả còn lại, phân loại bằng field "type":
///            "tour" | "booking" | "favorite" |
///            "message" | "notification" | "payment"
///
/// Cách dùng:
///   final user = await ApiService.login("a@b.com", "123456");
///   final tours = await ApiService.getTours();
/// ============================================================
class ApiService {

  // ============================================================
  // BASE URLs — Thay PROJECT_ID bằng ID project MockAPI của bạn
  // ============================================================
  static const String _base =
      "https://69e723af68208c1debe86172.mockapi.io/api/v1";

  static const String userUrl = "$_base/users";
  static const String dataUrl = "$_base/data";
  // ↑↑↑ Đảm bảo bạn đã tạo resource "data" trong cùng project với "users"

  // ============================================================
  // API 1 — ĐĂNG NHẬP
  // Màn hình: login_screen.dart
  // GET /users?email=... → tìm user, so sánh password
  // ============================================================
  static Future<User?> login(String email, String password) async {
    try {
      final res = await http
          .get(Uri.parse("$userUrl?email=$email"))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List users = jsonDecode(res.body);
        if (users.isNotEmpty) {
          final u = users.first;
          if (u['password'] == password) {
            return User.fromJson(u);
          }
        }
      }
    } catch (e) {
      print("[API1-Login] Error: $e");
    }
    return null; // null = sai thông tin
  }

  // ============================================================
  // API 2 — ĐĂNG KÝ
  // Màn hình: register_screen.dart
  // GET /users?email=... (check trùng) → POST /users
  // ============================================================
  static Future<({bool success, String message})> register({
    required String name,
    required String email,
    required String password,
    String avatar = "",
  }) async {
    try {
      // Kiểm tra email đã tồn tại
      final check = await http
          .get(Uri.parse("$userUrl?email=$email"))
          .timeout(const Duration(seconds: 10));

      if (check.statusCode == 200) {
        final List users = jsonDecode(check.body);
        if (users.isNotEmpty) {
          return (success: false, message: "Email đã được sử dụng");
        }
      }

      // Tạo tài khoản mới
      final res = await http.post(
        Uri.parse(userUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "avatar": avatar,
        }),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        return (success: true, message: "Đăng ký thành công");
      }
      return (success: false, message: "Đăng ký thất bại, thử lại sau");
    } catch (e) {
      print("[API2-Register] Error: $e");
      return (success: false, message: "Lỗi kết nối: $e");
    }
  }

  // ============================================================
  // API 3 — DANH SÁCH TOUR (Trang chủ)
  // Màn hình: tour_list_screen.dart
  // GET /data?type=tour
  // ============================================================
  static Future<List<Tour>> getTours() async {
    try {
      final res = await http
          .get(Uri.parse("$dataUrl?type=tour"))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Tour.fromJson(e)).toList();
      }
    } catch (e) {
      print("[API3-GetTours] Error: $e");
    }
    return _fallbackTours(); // Dùng data mẫu khi API lỗi
  }

  // ============================================================
  // API 4 — TÌM KIẾM TOUR
  // Màn hình: search_screen.dart
  // GET /data?type=tour → filter client-side theo query
  // ============================================================
  static Future<List<Tour>> searchTours(String query) async {
    final all = await getTours();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return all;
    return all.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.location.toLowerCase().contains(q);
    }).toList();
  }

  // ============================================================
  // API 5 — CHI TIẾT TOUR + YÊU THÍCH
  // Màn hình: tour_detail_screen.dart
  // GET  /data/:id     → lấy 1 tour theo ID
  // POST /data          → thêm yêu thích (type=favorite)
  // DELETE /data/:id   → xóa yêu thích
  // ============================================================
  static Future<Map<String, dynamic>?> getTourById(String id) async {
    try {
      final res = await http
          .get(Uri.parse("$dataUrl/$id"))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      print("[API5-GetTourById] Error: $e");
    }
    return null;
  }

  static Future<String?> addFavorite({
    required String userId,
    required String tourId,
    required String title,
    required String image,
    required String location,
    required int price,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(dataUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "type": "favorite",
          "userId": userId,
          "tourId": tourId,
          "title": title,
          "image": image,
          "location": location,
          "price": price,
        }),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['id']?.toString();
      }
    } catch (e) {
      print("[API5-AddFavorite] Error: $e");
    }
    return null;
  }

  static Future<bool> removeFavorite(String favoriteId) async {
    try {
      final res = await http.delete(Uri.parse("$dataUrl/$favoriteId"));
      return res.statusCode == 200;
    } catch (e) {
      print("[API5-RemoveFavorite] Error: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    try {
      final res = await http.get(
        Uri.parse("$dataUrl?type=favorite&userId=$userId"),
      );
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(res.body));
      }
    } catch (e) {
      print("[API5-GetFavorites] Error: $e");
    }
    return [];
  }

  // ============================================================
  // API 6 — CHUYẾN CỦA TÔI (My Trips)
  // Màn hình: my_trips_screen.dart
  // GET    /data?type=booking&userId=...
  // POST   /data (type=booking)
  // PUT    /data/:id           → đổi status
  // DELETE /data/:id           → xóa booking
  // ============================================================
  static Future<List<Map<String, dynamic>>> getBookings(String userId) async {
    try {
      final res = await http.get(
        Uri.parse("$dataUrl?type=booking&userId=$userId"),
      );
      if (res.statusCode == 200) {
        final List bookings = jsonDecode(res.body);
        final List<Map<String, dynamic>> result = [];

        for (final raw in bookings) {
          final booking = Map<String, dynamic>.from(raw);

          // Nếu booking không đủ dữ liệu tour, fetch tour theo tourId
          if ((booking['title'] == null || booking['image'] == null || booking['location'] == null) &&
              booking['tourId'] != null) {
            final tour = await getTourById(booking['tourId'].toString());
            if (tour != null) {
              booking['title'] = booking['title'] ?? tour['title'];
              booking['image'] = booking['image'] ?? tour['image'];
              booking['location'] = booking['location'] ?? tour['location'];
              booking['description'] = booking['description'] ?? tour['description'];
            }
          }

          result.add(booking);
        }
        return result;
      }
    } catch (e) {
      print("[API6-GetBookings] Error: $e");
    }
    return [];
  }

  static Future<bool> addBooking({
    required String userId,
    required String tourId,
    required String title,
    required String image,
    required String location,
    required int price,
    String status = "Next",
  }) async {
    try {
      final res = await http.post(
        Uri.parse(dataUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "type": "booking",
          "userId": userId,
          "tourId": tourId,
          "title": title,
          "image": image,
          "location": location,
          "price": price,
          "status": status,
          "bookingDate": DateTime.now().toIso8601String(),
        }),
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      print("[API6-AddBooking] Error: $e");
      return false;
    }
  }

  static Future<bool> updateBookingStatus(String id, String status) async {
    try {
      final res = await http.put(
        Uri.parse("$dataUrl/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": status}),
      );
      return res.statusCode == 200;
    } catch (e) {
      print("[API6-UpdateBooking] Error: $e");
      return false;
    }
  }

  static Future<bool> deleteBooking(String id) async {
    try {
      final res = await http.delete(Uri.parse("$dataUrl/$id"));
      return res.statusCode == 200;
    } catch (e) {
      print("[API6-DeleteBooking] Error: $e");
      return false;
    }
  }

  // ============================================================
  // API 7 — THÔNG BÁO
  // Màn hình: notifications_screen.dart
  // GET /data?type=notification&userId=...
  // ============================================================
  static Future<List<Map<String, dynamic>>> getNotifications(
      String userId) async {
    try {
      final res = await http.get(
        Uri.parse("$dataUrl?type=notification&userId=$userId"),
      );
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(res.body));
      }
    } catch (e) {
      print("[API7-GetNotifications] Error: $e");
    }
    return [];
  }

  // ============================================================
  // API 8 — HỒ SƠ NGƯỜI DÙNG
  // Màn hình: profile_screen.dart
  // GET /users/:id
  // PUT /users/:id
  // ============================================================
  static Future<User?> getUserProfile(String userId) async {
    try {
      final res = await http
          .get(Uri.parse("$userUrl/$userId"))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return User.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      print("[API8-GetProfile] Error: $e");
    }
    return null;
  }

  static Future<bool> updateProfile({
    required String userId,
    required String name,
    String? avatar,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{"name": name};
      if (avatar != null) body["avatar"] = avatar;
      if (phone != null) body["phone"] = phone;

      final res = await http.put(
        Uri.parse("$userUrl/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return res.statusCode == 200;
    } catch (e) {
      print("[API8-UpdateProfile] Error: $e");
      return false;
    }
  }

  // ============================================================
  // API 9 — TIN NHẮN / CHAT
  // Màn hình: chat_screen.dart
  // GET  /data?type=message&userId=...
  // POST /data (type=message)
  // ============================================================
  static Future<List<Map<String, dynamic>>> getMessages(String userId) async {
    try {
      final res = await http.get(
        Uri.parse("$dataUrl?type=message&userId=$userId"),
      );
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(res.body));
      }
    } catch (e) {
      print("[API9-GetMessages] Error: $e");
    }
    return [];
  }

  static Future<bool> sendMessage({
    required String userId,
    required String text,
    bool isMe = true,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(dataUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "type": "message",
          "userId": userId,
          "text": text,
          "isMe": isMe,
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      print("[API9-SendMessage] Error: $e");
      return false;
    }
  }

  // ============================================================
  // API 10 — THANH TOÁN
  // Màn hình: payment_screen.dart
  // POST /data (type=payment)
  // GET  /data?type=payment&userId=...
  // ============================================================
  static Future<bool> createPayment({
    required String userId,
    required String bookingId,
    required double amount,
    required String paymentMethod, // "credit_card" | "momo" | "zalopay"
    bool isDeposit = true,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(dataUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "type": "payment",
          "userId": userId,
          "bookingId": bookingId,
          "amount": amount,
          "depositAmount": isDeposit ? amount * 0.5 : amount,
          "paymentMethod": paymentMethod,
          "isDeposit": isDeposit,
          "status": "completed",
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      print("[API10-CreatePayment] Error: $e");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getPaymentHistory(
      String userId) async {
    try {
      final res = await http.get(
        Uri.parse("$dataUrl?type=payment&userId=$userId"),
      );
      if (res.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(res.body));
      }
    } catch (e) {
      print("[API10-GetPayments] Error: $e");
    }
    return [];
  }

  // ============================================================
  // FALLBACK DATA — Hiển thị khi API không trả về gì
  // ============================================================
  static List<Tour> _fallbackTours() {
    return [
      Tour(
        title: 'Tour Biển Đà Nẵng',
        price: 200,
        location: 'Đà Nẵng',
        image:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500&h=300&fit=crop',
        description: 'Khám phá những bãi biển xinh đẹp của Đà Nẵng',
      ),
      Tour(
        title: 'Du thuyền Hạ Long',
        price: 350,
        location: 'Quảng Ninh',
        image:
            'https://images.unsplash.com/photo-1528360983277-13d401cdc186?w=500&h=300&fit=crop',
        description: 'Trải nghiệm du thuyền di sản thế giới UNESCO',
      ),
      Tour(
        title: 'Phố cổ Hội An',
        price: 150,
        location: 'Hội An',
        image:
            'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=500&h=300&fit=crop',
        description: 'Khám phá phố cổ Hội An đèn lồng lung linh',
      ),
      Tour(
        title: 'Sapa Mùa Lúa Chín',
        price: 280,
        location: 'Lào Cai',
        image:
            'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=500&h=300&fit=crop',
        description: 'Ruộng bậc thang vàng óng và bản làng vùng cao',
      ),
    ];
  }
}