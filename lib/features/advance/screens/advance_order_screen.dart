import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/advance_service.dart';
import '../../../core/utils/role_helper.dart';

class AdvanceOrderScreen extends StatefulWidget {
  const AdvanceOrderScreen({super.key});

  @override
  State<AdvanceOrderScreen> createState() => _AdvanceOrderScreenState();
}

class _AdvanceOrderScreenState extends State<AdvanceOrderScreen> {
  bool _loading = true;
  bool _error = false;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadAdvances();
  }

  Future<void> _loadAdvances() async {
    try {
      final data = await AdvanceService.getAdvances();

      final activeOrders = data
          .where((o) => o['status'] != 'delivered')
          .toList();

      setState(() {
        _orders = activeOrders;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  /* --------------------------------------------------
     PARTIAL DELIVERY
  -------------------------------------------------- */
  void _openPartialDialog(dynamic order) {
    final qtyController = TextEditingController();
    final int maxQty = order['remainingQuantity'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Partial Delivery'),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Deliver Quantity (Max $maxQty)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(qtyController.text) ?? 0;

              if (qty <= 0 || qty > maxQty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Enter quantity between 1 and $maxQty'),
                  ),
                );
                return;
              }

              Navigator.pop(context);

              final success = await AdvanceService.partialDeliver(
                order['_id'],
                qty,
              );

              if (success) {
                _loadAdvances();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delivery recorded')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advance Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/advance-history'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/advance-create'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
          ? const Center(child: Text('Failed to load advance orders'))
          : _orders.isEmpty
          ? const Center(
              child: Text(
                'No active advance orders',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final customer = order['customerId'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 👤 CUSTOMER
                        Text(
                          customer?['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (customer?['mobile'] != null)
                          Text(
                            '📞 ${customer['mobile']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        if (customer?['address'] != null)
                          Text(
                            '📍 ${customer['address']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),

                        const Divider(height: 20),

                        // 📦 ORDER DETAILS
                        _row('Category', order['category']),
                        _row('Quantity', order['quantity'].toString()),
                        _row('Rate', '₹ ${order['rate']}'),
                        _row('Total', '₹ ${order['total']}'),

                        const SizedBox(height: 6),

                        _row(
                          'Advance Paid',
                          '₹ ${order['advance']}',
                          AppColors.success,
                        ),
                        _row(
                          'Remaining Balance',
                          '₹ ${order['remaining']}',
                          AppColors.danger,
                        ),

                        const SizedBox(height: 12),

                        // 🔐 OWNER ACTION
                        FutureBuilder<bool>(
                          future: RoleHelper.isOwner(),
                          builder: (context, snapshot) {
                            if (snapshot.data == true &&
                                order['status'] != 'delivered') {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _openPartialDialog(order),
                                  child: const Text('Deliver'),
                                ),
                              );
                            }

                            if (order['status'] == 'delivered') {
                              return const Text(
                                'Delivered',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }

                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _row(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
