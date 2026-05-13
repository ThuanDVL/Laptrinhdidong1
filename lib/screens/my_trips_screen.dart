import 'package:flutter/material.dart';
import '../models/tour.dart';
import '../services/api_service.dart';
import '../storage/app_data.dart';
import 'my_trip_detail_screen.dart';
import 'tour_detail_screen.dart';
import 'create_trip_screen.dart';
import 'payment_screen.dart';

class MyTripsScreen extends StatefulWidget {
  @override
  _MyTripsScreenState createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();

    // ✅ API 6 — Load bookings từ MockAPI khi mở màn hình
    _loadBookings();
  }

  /// ✅ Gọi API lấy bookings, convert Map -> Tour, lưu vào AppData
  Future<void> _loadBookings() async {
    final data = await ApiService.getBookings(AppData.userId);
    if (data.isEmpty) return; // giữ data local nếu API trống

    final fromApi = data.map((m) => Tour(
      title:       m['title']    ?? '',
      price:       (m['price'] as num?)?.toInt() ?? 0,
      location:    m['location'] ?? '',
      image:       m['image']    ?? '',
      description: m['description'] ?? '',
      status:      m['status']   ?? 'Next',
    )).toList();

    if (mounted) {
      setState(() {
        AppData.bookings
          ..clear()
          ..addAll(fromApi);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _openCreateNewTripDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateTripScreen()),
    );

    if (result is Tour) {
      setState(() => AppData.bookings.add(result));

      // ✅ Lưu chuyến mới lên MockAPI
      ApiService.addBooking(
        userId:   AppData.userId,
        tourId:   result.title,
        title:    result.title,
        image:    result.image,
        location: result.location,
        price:    result.price,
        status:   result.status,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm chuyến mới vào Chuyến của tôi')));
    }
  }

  List<Tour> _tripsByTab(int index) {
    if (index == 0) {
      return AppData.bookings.where((t) => t.status == 'Current').toList();
    } else if (index == 1) {
      return AppData.bookings.where((t) => t.status == 'Next').toList();
    } else if (index == 2) {
      return AppData.bookings.where((t) => t.status == 'Past').toList();
    } else {
      return AppData.favorites;
    }
  }

  Widget _buildTabPanel(int tabIndex, {bool isWishlist = false}) {
    List<Tour> trips = _tripsByTab(tabIndex);

    if (trips.isEmpty) {
      final emptyText = tabIndex == 3
          ? 'Chưa có chuyến trong danh sách yêu thích'
          : 'Chưa có chuyến trong mục này';
      
      if (tabIndex == 3) {
        // Wishlist empty state with gradient background
        return Center(
          child: FadeInUp(
            duration: Duration(milliseconds: 800),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleAnimation(
                    duration: Duration(milliseconds: 600),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00D1A3).withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 60,
                        color: Color(0xFF00D1A3),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    emptyText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Lưu các tour yêu thích để dễ dàng tìm lại sau',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 28),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00D1A3),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to search/browse screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hãy duyệt tour để yêu thích'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      'Khám phá tour',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      
      return Center(
        child: FadeInUp(
          duration: Duration(milliseconds: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleAnimation(
                duration: Duration(milliseconds: 600),
                child: Icon(Icons.airplanemode_active, size: 70, color: Colors.grey[400]),
              ),
              SizedBox(height: 14),
              Text(
                emptyText,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Thêm tour hoặc chuyển đặt chỗ đến tab này từ Trang chủ hoặc Yêu thích.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final staggerDelay = Duration(milliseconds: 50 + (index * 100));
        return SlideInAnimation(
          delay: staggerDelay,
          duration: Duration(milliseconds: 600),
          child: _tripCard(context, trips[index], index, isWishlist: isWishlist),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    IconData icon;
    switch (status) {
      case 'Current':
        bg = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'Next':
        bg = Colors.blue;
        icon = Icons.schedule;
        break;
      case 'Past':
        bg = Colors.grey;
        icon = Icons.history;
        break;
      case 'Wishlist':
        bg = Colors.purple;
        icon = Icons.favorite;
        break;
      default:
        bg = Colors.blue;
        icon = Icons.info;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(status, style: TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  void _showTripActions(Tour trip, int index, {bool isWishlist = false}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isWishlist) ...[
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Nhắn tin với hướng dẫn viên'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã mở chat cho ${trip.title}')));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.payment),
                  title: Text('Thanh toán ${trip.status == 'Next' ? 'đặt cọc' : 'toàn bộ'}'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tùy chọn thanh toán cho ${trip.title}')));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Đánh dấu đã hoàn thành'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      trip.status = 'Past';
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Xóa chuyến', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      AppData.bookings.remove(trip);
                    });
                  },
                ),
              ] else ...[
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Gỡ khỏi yêu thích', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      AppData.favorites.remove(trip);
                    });
                  },
                ),
                ListTile(
                  leading: Icon(Icons.close),
                  title: Text('Hủy'),
                  onTap: () => Navigator.pop(context),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Color(0xFF00D1A3),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF00D1A3),
              tabs: const [
                Tab(text: 'Hiện tại'),
                Tab(text: 'Tiếp theo'),
                Tab(text: 'Đã qua'),
                Tab(text: 'Yêu thích'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(4, (index) => _buildTabPanel(index, isWishlist: index == 3)),
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: Color(0xFF00D1A3),
              child: Icon(Icons.add),
              onPressed: _openCreateNewTripDialog,
            )
          : null,
    );
  }

  Widget _tripCard(BuildContext context, Tour trip, int index, {bool isWishlist = false}) {
    final displayStatus = isWishlist ? 'Wishlist' : trip.status;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => isWishlist
                  ? TourDetailScreen(tour: trip)
                  : MyTripDetailScreen(
                      tour: trip,
                      onMarkFinished: () {
                        setState(() {
                          trip.status = 'Past';
                        });
                      },
                    ),
            ),
          ).then((_) => setState(() {}));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    trip.image,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 170,
                      color: Colors.grey,
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: _buildStatusChip(displayStatus),
                ),
                Positioned(
                  right: 10,
                  top: 4,
                  child: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => _showTripActions(trip, index, isWishlist: isWishlist),
                    tooltip: 'More',
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trip.location,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${trip.price}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00D1A3)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            if (isWishlist) {
                              AppData.favorites.remove(trip);
                            } else {
                              AppData.bookings.remove(trip);
                            }
                          });
                        },
                        icon: Icon(Icons.delete_forever, color: Colors.red),
                        label: Text(isWishlist ? 'Xóa' : 'Hủy', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00D1A3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => isWishlist
                                  ? TourDetailScreen(tour: trip)
                                  : MyTripDetailScreen(
                                      tour: trip,
                                      onMarkFinished: () {
                                        setState(() {
                                          trip.status = 'Past';
                                        });
                                      },
                                      onDelete: () {
                                        setState(() {
                                          AppData.bookings.remove(trip);
                                        });
                                      },
                                    ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        child: Text('Chi tiết'),
                      ),
                      SizedBox(width: 8),
                      if (!isWishlist)
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mở chat cho ${trip.title}')));
                          },
                          child: Text('Nhắn tin'),
                        ),
                      if (isWishlist)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              AppData.favorites.remove(trip);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${trip.title} đã được gỡ khỏi yêu thích')));
                          },
                          child: Text('Xóa'),
                        ),
                      if (!isWishlist && trip.status == 'Next')
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PaymentScreen(tour: trip)),
                            );
                          },
                          child: Text('Thanh toán'),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Animation Widgets
class FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeInUp({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _offset = Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

class ScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ScaleAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
  }
}

class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const SlideInAnimation({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _offset = Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    // Schedule animation after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(widget.delay, () {
          if (mounted && !_controller.isAnimating) {
            _controller.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: widget.child,
    );
  }
}
