import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'payment_history_screen.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../storage/app_data.dart';

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({super.key, required this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryColor = const Color(0xFF00D1A3);
  User? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  String get userName => _profile?.name ?? AppData.currentUserName ?? widget.email.split('@').first;

  Future<void> _loadProfile() async {
    if (AppData.currentUserId == null) {
      setState(() => _isLoadingProfile = false);
      return;
    }

    final profile = await ApiService.getUserProfile(AppData.currentUserId!);
    if (profile != null) {
      AppData.setSession(profile, id: profile.id);
    }
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });
    }
  }

  void editName() {
    final controller = TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sửa tên"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nhập tên mới"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                // ✅ Gọi API cập nhật tên
                if (AppData.currentUserId != null) {
                  await ApiService.updateProfile(
                    userId: AppData.currentUserId!,
                    name: controller.text,
                  );
                }
                AppData.currentUserName = controller.text;
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: const Color(0xFFEFF7F5),
                    child: ClipOval(
                      child: Image.network(
                        AppData.currentUserAvatar?.isNotEmpty == true
                            ? AppData.currentUserAvatar!
                            : "https://randomuser.me/api/portraits/men/1.jpg",
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFEFF7F5),
                            child: Icon(Icons.person, size: 45, color: primaryColor),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.email,
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: editName,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Sửa"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _sectionHeader("Yêu thích của tôi"),
                  const SizedBox(height: 12),
                  if (AppData.favorites.isEmpty)
                    _emptyState(Icons.favorite_border, "Chưa có yêu thích")
                  else
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppData.favorites.length,
                        itemBuilder: (context, index) {
                          final tour = AppData.favorites[index];
                          return _imageCard(tour.image, tour.title, () {
                            setState(() {
                              AppData.favorites.removeAt(index);
                            });
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  _sectionHeader("Đặt chỗ của tôi"),
                  const SizedBox(height: 12),
                  if (AppData.bookings.isEmpty)
                    _emptyState(Icons.card_travel_outlined, "Chưa có đặt chỗ")
                  else
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppData.bookings.length,
                        itemBuilder: (context, index) {
                          final tour = AppData.bookings[index];
                          return _imageCard(tour.image, tour.title, () {
                            setState(() {
                              AppData.bookings.removeAt(index);
                            });
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildMenuItem(Icons.notifications, "Thông báo", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.language, "Ngôn ngữ"),
                  _buildMenuItem(Icons.payment, "Thanh toán", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.lock, "Quyền riêng tư"),
                  _buildMenuItem(Icons.feedback, "Phản hồi"),
                  _buildMenuItem(
                    Icons.chat_bubble_outline,
                    "Tin nhắn",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      // ✅ Xóa session khi đăng xuất
                      AppData.clearSession();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Đăng xuất',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return SizedBox(
      height: 140,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _imageCard(String imageUrl, String title, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: SizedBox(
        width: 150,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 150,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 140,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 40),
                  );
                },
              ),
            ),
            Container(
              width: 150,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [Colors.black26, Colors.black54],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
