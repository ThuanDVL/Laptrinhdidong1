import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../storage/app_data.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<Map<String, dynamic>> _paymentHistory = [];
  bool _isLoading = true;

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
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử thanh toán'),
        backgroundColor: const Color(0xFF00D1A3),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00D1A3),
              ),
            )
          : _paymentHistory.isEmpty
              ? const Center(
                  child: Text('Chưa có lịch sử thanh toán'),
                )
              : ListView.builder(
                  itemCount: _paymentHistory.length,
                  itemBuilder: (context, index) {
                    final payment = _paymentHistory[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.payment, color: Color(0xFF00D1A3)),
                        title: Text('Thanh toán #${payment['id'] ?? index + 1}'),
                        subtitle: Text('Số tiền: \$${payment['amount'] ?? 'N/A'}'),
                        trailing: Text(payment['date'] ?? 'N/A'),
                      ),
                    );
                  },
                ),
    );
  }
}