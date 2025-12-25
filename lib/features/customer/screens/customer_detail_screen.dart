import 'package:flutter/material.dart';
import '../../../services/sales_service.dart';
import 'sale_detail_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _loading = true;
  List<dynamic> _sales = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data =
        await SalesService.getSalesByCustomer(widget.customerId);
    setState(() {
      _sales = data;
      _loading = false;
    });
  }

  String _formatDate(String iso) {
    final d = DateTime.parse(iso);
    return '${d.day}-${d.month}-${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Sales')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sales.isEmpty
              ? const Center(child: Text('No sales found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sales.length,
                  itemBuilder: (_, i) {
                    final s = _sales[i];

                    final int total = s['total'] ?? 0;
                    final int paid = s['paid'] ?? 0;
                    final int due = s['due'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          _formatDate(s['createdAt']),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Category: ${s['category']}'),
                            Text('Quantity: ${s['quantity']}'),
                            Text('Total: ₹$total'),
                            Text(
                              'Paid: ₹$paid',
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Due: ₹$due',
                              style: TextStyle(
                                color: due > 0
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SaleDetailScreen(
                                saleId: s['_id'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
