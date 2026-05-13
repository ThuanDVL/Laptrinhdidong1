import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/tour.dart';
import 'tour_detail_screen.dart';
import 'search_screen.dart';

class TourListScreen extends StatefulWidget {
  @override
  _TourListScreenState createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  late Future<List<Tour>> tours;
  List<Tour> allTours = [];
  List<Tour> filteredTours = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tours = ApiService.getTours();
    tours.then((data) {
      setState(() {
        allTours = data;
        filteredTours = data;
      });
    });
  }

  void searchTour(String query) {
    final input = query.trim().toLowerCase();
    setState(() {
      if (input.isEmpty) {
        filteredTours = allTours;
        return;
      }
      filteredTours = allTours.where((tour) {
        final title = tour.title.toLowerCase();
        final location = tour.location.toLowerCase();
        return title.contains(input) || location.contains(input);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: FutureBuilder<List<Tour>>(
        future: tours,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Color(0xFF00D1A3)),
              ),
            );
          }

          final data = snapshot.data ?? [];
          final displayedTours = filteredTours.isNotEmpty ? filteredTours : data;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Khám phá',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Bạn muốn khám phá đâu?',
                              style: TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.wb_sunny_outlined, color: Color(0xFF00D1A3), size: 26),
                            SizedBox(height: 6),
                            Text('26°C', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Da Nang', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: const Icon(Icons.search, color: Color(0xFF00D1A3)),
                      title: TextField(
                        controller: searchController,
                        readOnly: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SearchScreen()),
                          );
                        },
                        decoration: const InputDecoration(
                          hintText: 'Chào bạn, bạn muốn khám phá đâu?',
                          border: InputBorder.none,
                        ),
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D1A3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.tune, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionHeader('Hành trình hàng đầu', 'Xem tất cả'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.length < 4 ? data.length : 4,
                      itemBuilder: (context, index) => _topJourneyCard(data[index]),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionHeader('Hướng dẫn viên nổi bật', 'Xem tất cả'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _buildGuideCards(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionHeader('Trải nghiệm hàng đầu', null),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _buildExperienceCards(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionHeader('Tour nổi bật', null),
                  const SizedBox(height: 16),
                  Column(
                    children: displayedTours.map((tour) => _featuredTourCard(tour)).toList(),
                  ),
                  const SizedBox(height: 28),
                  _sectionHeader('Tin tức du lịch', null),
                  const SizedBox(height: 16),
                  Column(
                    children: _buildNewsCards(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        if (action != null)
          Text(
            action,
            style: const TextStyle(fontSize: 13, color: Color(0xFF00D1A3), fontWeight: FontWeight.w600),
          ),
      ],
    );
  }

  Widget _topJourneyCard(Tour tour) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour)),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(tour.image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                tour.location,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                tour.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '\$${tour.price}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGuideCards() {
    final List<Map<String, String>> guides = [
      {'name': 'Linh Hoa', 'location': 'Hoian, Vietnam', 'rating': '4.9'},
      {'name': 'Tuấn Trần', 'location': 'Danang, Vietnam', 'rating': '4.8'},
      {'name': 'Kiều Hà', 'location': 'Hoi An, Vietnam', 'rating': '4.7'},
    ];

    return guides.map((guide) {
      return InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã chọn hướng dẫn viên ${guide['name']}')),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF00D1A3),
                child: Text(
                  guide['name']![0],
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                guide['name']!,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                guide['location']!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFB800)),
                  const SizedBox(width: 6),
                  Text(
                    guide['rating']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildExperienceCards() {
    final List<Map<String, Object>> experienceData = [
      {'title': 'Tour thành phố', 'subtitle': '2-4 giờ', 'color': const Color(0xFFF8E9E1)},
      {'title': 'Tour ẩm thực', 'subtitle': 'Hương vị địa phương', 'color': const Color(0xFFE8F3FF)},
      {'title': 'Phiêu lưu', 'subtitle': 'Trải nghiệm ngoài trời', 'color': const Color(0xFFEAF7EC)},
    ];

    return experienceData.map((item) {
      return InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã chọn ${item['title']}')),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 150,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item['color'] as Color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.explore, color: Color(0xFF00D1A3), size: 28),
              const Spacer(),
              Text(
                item['title'] as String,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                item['subtitle'] as String,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _featuredTourCard(Tour tour) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour)),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: Image.network(
                tour.image,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tour.location,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                      Text(
                        '\$${tour.price}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00D1A3)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNewsCards() {
    final news = [
      {'title': 'Tin tức du lịch Đà Nẵng', 'subtitle': 'Ưu đãi mùa hè mới đang có'},
      {'title': 'Khám phá Hàn Quốc mùa thu', 'subtitle': 'Top 10 hành trình và ưu đãi'},
    ];

    return news.map((Map<String, String> item) {
      return InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã chọn ${item['title']}')),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title']!,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                item['subtitle']!,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

}
