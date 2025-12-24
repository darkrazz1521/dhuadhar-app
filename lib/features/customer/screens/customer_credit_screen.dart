import 'package:flutter/material.dart';
import '../../../services/credit_service.dart';

class CustomerCreditScreen extends StatefulWidget {
  final String customerId;
  const CustomerCreditScreen({super.key, required this.customerId});

  @override
  State<CustomerCreditScreen> createState() =>
      _CustomerCreditScreenState();
}

class _CustomerCreditScreenState
    extends State<CustomerCreditScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data =
        await CreditService.getCustomerSummary(
      widget.customerId,
    );
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final customer = _data!['customer'];
    final sales = _data!['sales'] as List;
    final payments = _data!['payments'] as List;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Credit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // CUSTOMER HEADER
          Text(
            customer['name'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text('📞 ${customer['mobile']}'),
          Text('📍 ${customer['address']}'),

          const SizedBox(height: 16),

          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Due',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '₹${_data!['totalDue']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Due Sales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          for (final s in sales)
            ListTile(
              title: Text(
                '₹${s['dueAmount']} due',
                style:
                    const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                DateTime.parse(s['createdAt'])
                    .toLocal()
                    .toString()
                    .substring(0, 10),
              ),
            ),

          const SizedBox(height: 20),

          const Text(
            'Payment History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (payments.isEmpty)
            const Text('No payments yet'),

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
