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
      setState(() {
        _orders = data;
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
     🧱 PARTIAL DELIVERY DIALOG
  -------------------------------------------------- */
  void _openPartialDialog(dynamic order) {
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Partial Delivery'),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText:
                'Deliver Quantity (Max ${order['remainingQuantity']})',
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

              final success =
                  await AdvanceService.partialDeliver(
                order['_id'],
                qty,
              );

              Navigator.pop(context);

              if (success) {
                _loadAdvances();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delivery recorded'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delivery failed'),
                  ),
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
          // 📜 ADVANCE HISTORY
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/advance-history');
            },
          ),

          // ➕ ADD ADVANCE ORDER
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/advance-create');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? const Center(
                  child: Text('Failed to load advance orders'),
                )
              : _orders.isEmpty
                  ? const Center(
                      child: Text('No advance orders'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];

                        final int advance = order['advance'];
                        final int remaining = order['remaining'];
                        final bool delivered =
                            order['status'] == 'delivered';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              order['customerId']['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('Brick: ${order['category']}'),
                                Text(
                                    'Quantity: ${order['quantity']}'),
                                Text('Rate: ₹ ${order['rate']}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Adv: ₹ $advance',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Due: ₹ $remaining',
                                  style: TextStyle(
                                    color: remaining > 0
                                        ? AppColors.danger
                                        : AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // 🔐 OWNER ONLY ACTION
                                FutureBuilder<bool>(
                                  future: RoleHelper.isOwner(),
                                  builder: (context, snapshot) {
                                    if (snapshot.data == true &&
                                        !delivered) {
                                      return TextButton(
                                        onPressed: () =>
                                            _openPartialDialog(
                                                order),
                                        child:
                                            const Text('Deliver'),
                                      );
                                    }

                                    if (delivered) {
                                      return const Text(
                                        'Delivered',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }

                                    // 👤 STAFF SEES NOTHING
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
}
