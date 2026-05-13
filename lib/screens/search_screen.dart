import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/tour.dart';
import 'tour_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Tour> allTours = [];
  List<Tour> filteredTours = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTours();
  }

  void loadTours() async {
    final tours = await ApiService.getTours();
    setState(() {
      allTours = tours;
      filteredTours = tours;
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tìm kiếm',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Tìm và khám phá chuyến đi tiếp theo của bạn',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.filter_list, color: Color(0xFF00D1A3)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  leading: const Icon(Icons.search, color: Color(0xFF00D1A3)),
                  title: TextField(
                    controller: searchController,
                    onChanged: searchTour,
                    decoration: const InputDecoration(
                        hintText: 'Tìm hướng dẫn, tour...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Hướng dẫn'),
                    _buildFilterChip('Tour'),
                    _buildFilterChip('Khách sạn'),
                    _buildFilterChip('Chuyến bay'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: filteredTours.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Không tìm thấy kết quả',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const Text(
                            'Hướng dẫn viên tại Đà Nẵng',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 170,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _buildGuideProfileCards(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Tour tại Đà Nẵng',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 14),
                          Column(
                            children: filteredTours.map((tour) => _buildSearchTourCard(tour)).toList(),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String title) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      ),
    );
  }

  List<Widget> _buildGuideProfileCards() {
    final List<Map<String, String>> guides = [
      {'name': 'Linh Hoa', 'location': 'Danang, Vietnam', 'rate': '4.9'},
      {'name': 'Linh Nam', 'location': 'Hoi An, Vietnam', 'rate': '4.8'},
      {'name': 'Khải Hà', 'location': 'Hue, Vietnam', 'rate': '4.7'},
    ];

    return guides.map((Map<String, String> guide) {
      return Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF00D1A3),
              child: Text(
                guide['name']![0],
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE9FFF8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                  const SizedBox(width: 6),
                  Text(
                    guide['rate']!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSearchTourCard(Tour tour) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
            child: Image.network(
              tour.image,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tour.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${tour.price}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF00D1A3)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9FFF8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Xem thêm',
                          style: TextStyle(color: Color(0xFF00D1A3), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

