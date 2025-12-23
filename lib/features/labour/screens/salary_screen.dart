import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final String _month =
      DateTime.now().toIso8601String().substring(0, 7);
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data =
        await PaymentService.getSalaryLabours(_month);
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  void _pay(dynamic l) {
    showDialog(
      context: context,
      builder: (_) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: Text('Pay ${l['name']}'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final ok =
                    await PaymentService.paySalary({
                  'labourId': l['labourId'],
                  'month': _month,
                  'amount':
                      int.tryParse(ctrl.text) ?? 0,
                });
                if (ok && mounted) {
                  Navigator.pop(context);
                  _load();
                }
              },
              child: const Text('Pay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salary Labour')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final l = _items[i];
                return Card(
                  child: ListTile(
                    title: Text(l['name']),
                    subtitle: Text(
                        '${l['type']} | Salary: ₹${l['monthlySalary']}'),
                    trailing: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text('Paid: ₹${l['paid']}'),
                        Text(
                          'Pending: ₹${l['pending']}',
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        TextButton(
                          onPressed: l['pending'] > 0
                              ? () => _pay(l)
                              : null,
                          child: const Text('Pay'),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
