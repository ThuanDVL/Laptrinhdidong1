import 'package:flutter/material.dart';
import '../models/tour.dart';
import '../services/api_service.dart';
import '../storage/app_data.dart';

class TourDetailScreen extends StatefulWidget {
  final Tour tour;

  const TourDetailScreen({required this.tour});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  final Color primaryColor = const Color(0xFF00D1A3);

  bool isFavorite = false;
  String? _favoriteId;

  @override
  void initState() {
    super.initState();
    isFavorite = AppData.favorites.any((t) => t.title == widget.tour.title && t.location == widget.tour.location);
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    if (widget.tour.id == null) return;
    final favorites = await ApiService.getFavorites(AppData.userId);
    for (final item in favorites) {
      if (item['tourId']?.toString() == widget.tour.id) {
        if (!mounted) return;
        setState(() {
          isFavorite = true;
          _favoriteId = item['id']?.toString();
        });
        return;
      }
    }
  }

  void _toggleFavorite() async {
    final tour = widget.tour;
    final tourId = tour.id ?? tour.title;

    if (!isFavorite) {
      final favoriteId = await ApiService.addFavorite(
        userId: AppData.userId,
        tourId: tourId,
        title: tour.title,
        image: tour.image,
        location: tour.location,
        price: tour.price,
      );
      if (favoriteId != null) {
        AppData.favorites.add(tour.copyWith(status: 'Wishlist'));
        _favoriteId = favoriteId;
        if (mounted) {
          setState(() => isFavorite = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm vào yêu thích')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thêm yêu thích thất bại')),
          );
        }
      }
    } else {
      if (_favoriteId != null) {
        await ApiService.removeFavorite(_favoriteId!);
      } else {
        final favorites = await ApiService.getFavorites(AppData.userId);
        for (final item in favorites) {
          if (item['tourId']?.toString() == tourId) {
            final id = item['id']?.toString();
            if (id != null) {
              await ApiService.removeFavorite(id);
              break;
            }
          }
        }
      }
      AppData.favorites.removeWhere((t) => t.title == tour.title && t.location == tour.location);
      if (mounted) {
        setState(() {
          isFavorite = false;
          _favoriteId = null;
        });
        // ✅ Clear any existing SnackBars before showing new one
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã bỏ yêu thích')),
        );
      }
    }
  }

  void _bookTour() async {
    final tour = widget.tour;
    final alreadyBooked = AppData.bookings.any(
      (t) => t.title == tour.title && t.location == tour.location);

    if (alreadyBooked) {
      // ✅ Clear any existing SnackBars before showing new one
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tour đã có trong đặt chỗ của bạn'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ Lưu local ngay để UI phản hồi nhanh
    AppData.bookings.add(tour);

    // ✅ Gọi API lưu lên MockAPI (background)
    ApiService.addBooking(
      userId:   AppData.userId,
      tourId:   tour.title,
      title:    tour.title,
      image:    tour.image,
      location: tour.location,
      price:    tour.price,
      status:   'Next',
    );

    // ✅ Clear any existing SnackBars before showing new one
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đặt tour thành công! 🎉'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF00D1A3),
      ),
    );

    // ✅ Navigate back after showing success message
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 260,
                  child: Image.network(
                    tour.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 48, color: Colors.white70),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              'https://randomuser.me/api/portraits/men/29.jpg',
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 52,
                                height: 52,
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, color: Colors.white70, size: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Tuan Tran',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Hướng dẫn viên chuyên nghiệp tại Đà Nẵng',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '4.9 • 152 reviews',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D1A3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text('Chọn hướng dẫn viên'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[600],
                            ),
                            onPressed: _toggleFavorite,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        tour.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${tour.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D1A3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Trip Information
                  const Text(
                    'Thông tin chuyến đi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(Icons.calendar_today, 'Ngày', '28/03/2026'),
                        const Divider(),
                        _buildFeatureRow(Icons.access_time, 'Thời lượng', '3 ngày / 2 đêm'),
                        const Divider(),
                        _buildFeatureRow(Icons.group, 'Số người', '2-4 người'),
                        const Divider(),
                        _buildFeatureRow(Icons.place, 'Thành phố', tour.location),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // My Experiences
                  const Text(
                    'Kinh nghiệm của tôi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      _buildExperienceItem('Tour xe đạp 2 giờ khám phá thành phố', '24/01/2026', 142),
                      const SizedBox(height: 8),
                      _buildExperienceItem('Tour ẩm thực tại Đà Nẵng', '20/01/2026', 96),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Reviews
                  const Text(
                    'Đánh giá',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildReviewItem('Pena Valdez', '“He was fantastic, really friendly and knowledgeable.”', '2 days ago'),
                  const SizedBox(height: 10),
                  _buildReviewItem('Kerri Barber', '“Great experience, worth every penny.”', '5 days ago'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            ElevatedButton.icon(
              onPressed: _toggleFavorite,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.black54,
              ),
              label: Text(isFavorite ? 'Đã thích' : 'Thêm tim'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFavorite ? Colors.red.shade100 : Colors.grey.shade200,
                foregroundColor: isFavorite ? Colors.red : Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _bookTour,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D1A3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Đặt ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(String title, String date, int likes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star, color: Color(0xFF00D1A3), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Text(likes.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String comment, String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.network(
                  'https://randomuser.me/api/portraits/women/65.jpg',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 32,
                    height: 32,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.white70, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}