import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../storage/app_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  /// ✅ API 7 — Load thông báo từ MockAPI /data?type=notification
  Future<void> _loadNotifications() async {
    final data = await ApiService.getNotifications(AppData.userId);

    if (!mounted) return;
    setState(() {
      _notifications = data;
      _isLoading = false;
    });
  }

  IconData _iconFromString(String? icon) {
    switch (icon) {
      case 'check':  return Icons.check_circle_outline;
      case 'offer':  return Icons.local_offer;
      case 'done':   return Icons.done_all;
      default:       return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00D1A3),
              ),
            )
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 72, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Không có thông báo nào',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF00D1A3),
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final dateStr = (item['date'] as String?) ?? (item['createdAt'] as String?) ?? '';
                      final body = (item['subtitle'] as String?) ?? (item['message'] as String?) ?? '';
                      DateTime? date;
                      try { date = DateTime.parse(dateStr); } catch (_) {}

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.blue.shade50,
                                child: Icon(
                                  _iconFromString(item['icon'] as String?),
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String? ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      body,
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 6),
                                    if (date != null)
                                      Text(
                                        '${date.day}/${date.month}/${date.year}',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 11),
                                      ),
                                    if (item['withAction'] == true)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF00D1A3),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            minimumSize:
                                                const Size(120, 36),
                                          ),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Cảm ơn bạn đã đánh giá ${item['tourTitle'] ?? 'tour'}!'),
                                            ));
                                          },
                                          child: const Text('Đánh giá',
                                              style:
                                                  TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
