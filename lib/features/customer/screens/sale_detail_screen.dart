import 'package:flutter/material.dart';
import '../../../services/sales_service.dart';


class SaleDetailScreen extends StatefulWidget {
  final String saleId;
  const SaleDetailScreen({super.key, required this.saleId});

  @override
  State<SaleDetailScreen> createState() =>
      _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data =
        await SalesService.getSaleDetail(widget.saleId);
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Widget _row(String label, dynamic value,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sale = _data!['sale'];
    final payments = _data!['payments'] as List;

    return Scaffold(
      appBar: AppBar(title: const Text('Sale Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SALE INFO
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _row('Quantity', sale['quantity']),
                  _row('Rate', '₹${sale['rate']}'),
                  _row('Total', '₹${sale['totalAmount']}'),
                  _row(
                    'Paid',
                    '₹${sale['paidAmount']}',
                    color: Colors.green,
                  ),
                  _row(
                    'Due',
                    '₹${sale['dueAmount']}',
                    color: sale['dueAmount'] > 0
                        ? Colors.red
                        : Colors.green,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Payment History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          if (payments.isEmpty)
            const Text('No payments recorded'),

          for (final p in payments)
            ListTile(
              leading:
                  const Icon(Icons.payments_outlined),
              title: Text('₹${p['amount']}'),
              subtitle: Text(
                DateTime.parse(p['createdAt'])
                    .toLocal()
                    .toString()
                    .substring(0, 16),
              ),
            ),
        ],
      ),
    );
  }
}
