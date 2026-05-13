import 'package:flutter/material.dart';
import '../models/tour.dart';
import '../services/api_service.dart';
import '../storage/app_data.dart';

class PaymentScreen extends StatefulWidget {
  final Tour tour;

  const PaymentScreen({super.key, required this.tour});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _goToConfirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentCheckoutScreen(tour: widget.tour),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Thông tin thẻ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên chủ thẻ', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter card hold name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Số thẻ', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter card number';
                  if (value.replaceAll(' ', '').length < 16) return 'Card number invalid';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(labelText: 'Ngày hết hạn', hintText: 'mm/yy', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Enter expiry date';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Enter CVV';
                        if (value.trim().length < 3) return 'Invalid CVV';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D1A3), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _goToConfirm,
                child: const Text('Tiếp theo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentCheckoutScreen extends StatefulWidget {
  final Tour tour;

  const PaymentCheckoutScreen({super.key, required this.tour});

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  List<Map<String, dynamic>> _paymentHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    final data = await ApiService.getPaymentHistory(AppData.userId);
    if (!mounted) return;
    setState(() {
      _paymentHistory = data;
      _isLoadingHistory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;
    final double total = tour.price.toDouble();
    final double deposit = total * 0.5;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Kiểm tra & thanh toán', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tour: ${tour.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Ngày: ${_extractValue(tour.description, 'Date') ?? 'Chưa xác định'}'),
                    const SizedBox(height: 4),
                    Text('Thời gian: ${_extractValue(tour.description, 'Time') ?? 'Chưa xác định'}'),
                    const SizedBox(height: 4),
                    Text('Số người: ${_extractValue(tour.description, 'Travelers') ?? '1'}'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00D1A3), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Đặt cọc 50%'),
                        Text('\$${deposit.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D1A3),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final bookingId = widget.tour.id ?? widget.tour.title;
                final success = await ApiService.createPayment(
                  userId: AppData.userId,
                  bookingId: bookingId,
                  amount: total,
                  paymentMethod: 'credit_card',
                  isDeposit: true,
                );

                if (!mounted) return;
                if (success) {
                  await _loadPaymentHistory();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Thành công ✅'),
                      content: const Text('Thanh toán hoàn tất! Chúc bạn có chuyến đi vui vẻ.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.popUntil(ctx, (r) => r.isFirst),
                          child: const Text('Xong'),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thanh toán thất bại, thử lại sau')),
                  );
                }
              },
              child: const Text(
                'Thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Lịch sử thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_isLoadingHistory)
              const Center(child: CircularProgressIndicator())
            else if (_paymentHistory.isEmpty)
              const Text('Chưa có lịch sử thanh toán', style: TextStyle(color: Colors.grey))
            else
              Column(
                children: _paymentHistory.map((payment) {
                  final createdAt = payment['timestamp'] ?? payment['createdAt'] ?? '';
                  final date = DateTime.tryParse(createdAt.toString());
                  final method = payment['paymentMethod']?.toString() ?? 'Unknown';
                  final status = payment['status']?.toString() ?? 'pending';
                  final amountValue = payment['amount'];
                  final amount = (amountValue is num) ? amountValue.toDouble() : double.tryParse(amountValue?.toString() ?? '0') ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(payment['tourId']?.toString() ?? 'Tour đã đặt', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Số tiền: \$${amount.toStringAsFixed(2)}'),
                          const SizedBox(height: 4),
                          Text('Phương thức: $method'),
                          const SizedBox(height: 4),
                          Text('Trạng thái: $status'),
                          if (date != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  String? _extractValue(String description, String key) {
    final lines = description.split('\n');
    for (var line in lines) {
      if (line.toLowerCase().startsWith('${key.toLowerCase()}:')) {
        return line.split(':').sublist(1).join(':').trim();
      }
    }
    return null;
  }
}
