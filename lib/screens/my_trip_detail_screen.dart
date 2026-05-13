import 'package:flutter/material.dart';
import '../models/tour.dart';

class MyTripDetailScreen extends StatefulWidget {
  final Tour tour;
  final VoidCallback? onMarkFinished;
  final VoidCallback? onDelete;

  const MyTripDetailScreen({super.key, required this.tour, this.onMarkFinished, this.onDelete});

  @override
  State<MyTripDetailScreen> createState() => _MyTripDetailScreenState();
}

class _MyTripDetailScreenState extends State<MyTripDetailScreen> {
  late Tour tour;

  final List<GuideOffer> _offers = [
    GuideOffer(name: 'Khai Ho', rating: 4.9, price: 18, detail: 'Phản hồi nhanh, hiểu biết địa phương'),
    GuideOffer(name: 'Tran Thao', rating: 4.8, price: 15, detail: 'Thân thiện và giàu kinh nghiệm'),
    GuideOffer(name: 'Henry', rating: 4.7, price: 12, detail: 'Tiết kiệm và nhận được phản hồi tốt'),
  ];

  @override
  void initState() {
    super.initState();
    tour = widget.tour;
  }

  void _markFinished() {
    setState(() {
      tour.status = 'Past';
    });
    widget.onMarkFinished?.call();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đánh dấu hoàn thành')));
  }

  String get _date => _extractInfo('Date') ?? 'TBD';
  String get _time => _extractInfo('Time') ?? 'TBD';
  String get _numTravelers => _extractInfo('Travelers') ?? '1';
  List<String> get _attractions {
    final text = _extractInfo('Attractions');
    if (text == null || text.isEmpty) return [];
    return text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  String? _extractInfo(String key) {
    final lines = tour.description.split('\n');
    for (var line in lines) {
      if (line.toLowerCase().startsWith('${key.toLowerCase()}:')) {
        return line.split(':').sublist(1).join(':').trim();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    tour.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tour.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(tour.location, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _infoTile('Date', _date)),
                          const SizedBox(width: 8),
                          Expanded(child: _infoTile('Time', _time)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _infoTile('Hướng dẫn viên', 'Hướng dẫn viên địa phương'),
                      const SizedBox(height: 10),
                      _infoTile('Số người', _numTravelers),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _attractions
                            .map((a) => Chip(label: Text(a), backgroundColor: Colors.green.shade50))
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      const Text('Ưu đãi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ..._offers.map((offer) => _buildOfferCard(offer)).toList(),
                      const SizedBox(height: 10),
                      if (tour.status == 'Next')
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Vui lòng chờ hướng dẫn viên xác nhận', style: TextStyle(color: Colors.black87)),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Phí', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('\$${tour.price}.00', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00D1A3))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStatus(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.black87),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Sửa chuyến này'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng sửa chuyến chưa được hỗ trợ')));
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                                  title: const Text('Xóa chuyến này', style: TextStyle(color: Colors.red)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Xóa chuyến này'),
                                        content: const Text('Bạn có chắc muốn xóa chuyến này không?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              widget.onDelete?.call();
                                            },
                                            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.close),
                                  title: const Text('Hủy'),
                                  onTap: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: tour.status == 'Past' ? null : _markFinished,
          style: ElevatedButton.styleFrom(
            backgroundColor: tour.status == 'Past' ? Colors.grey : const Color(0xFF00D1A3),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(tour.status == 'Past' ? 'Đã hoàn thành' : 'Đánh dấu hoàn thành', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildOfferCard(GuideOffer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Text(offer.name.substring(0, 1)),
        ),
        title: Text(offer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${offer.rating} • ${offer.detail}'),
            const SizedBox(height: 4),
            Text('\$${offer.price}/hr', style: const TextStyle(color: Color(0xFF00D1A3), fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: offer.selected
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Text('Đã chọn', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat),
                    title: const Text('Chat với hướng dẫn viên'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bắt đầu chat với ${offer.name}')));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.check),
                    title: Text('Chọn ${offer.name}'),
                    onTap: () {
                      setState(() {
                        for (final o in _offers) o.selected = false;
                        offer.selected = true;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text('Hủy'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatus() {
    final color = tour.status == 'Past' ? Colors.grey : Colors.blue;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(tour.status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class GuideOffer {
  final String name;
  final double rating;
  final int price;
  final String detail;
  bool selected;

  GuideOffer({required this.name, required this.rating, required this.price, required this.detail, this.selected = false});
}