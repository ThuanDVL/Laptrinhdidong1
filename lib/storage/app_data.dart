import '../models/tour.dart';
import '../models/user.dart';

/// Lưu trữ session người dùng đang đăng nhập + dữ liệu local tạm thời
class AppData {

  // ============================================================
  // SESSION — User đang đăng nhập
  // ============================================================
  static String? currentUserId;    // ID user trên MockAPI
  static String? currentUserName;  // Tên hiển thị
  static String? currentUserEmail;
  static String? currentUserAvatar;

  /// Gọi sau khi login thành công
  static void setSession(User user, {String? id}) {
    currentUserId   = id ?? user.id ?? user.email; // MockAPI dùng id tự sinh
    currentUserName = user.name;
    currentUserEmail = user.email;
    currentUserAvatar = user.avatar;
  }

  /// Xóa session khi logout
  static void clearSession() {
    currentUserId   = null;
    currentUserName = null;
    currentUserEmail = null;
    currentUserAvatar = null;
    bookings.clear();
    favorites.clear();
  }

  /// Lấy userId an toàn (fallback về email nếu chưa có id)
  static String get userId => currentUserId ?? currentUserEmail ?? "guest";

  // ============================================================
  // LOCAL CACHE — Vẫn giữ để app không lỗi khi offline
  // Được đồng bộ từ API khi load màn hình
  // ============================================================
  static List<Tour> bookings  = [];
  static List<Tour> favorites = [];
}