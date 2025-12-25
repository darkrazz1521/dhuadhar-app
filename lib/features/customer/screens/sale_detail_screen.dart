import 'package:flutter/material.dart';

import '../../../services/sales_service.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/role_helper.dart';

class SaleDetailScreen extends StatefulWidget {
  final String saleId;

  const SaleDetailScreen({
    super.key,
    required this.saleId,
  });

  @override
  State<SaleDetailScreen> createState() =>
      _SaleDetailScreenState();
}

class _SaleDetailScreenState
    extends State<SaleDetailScreen> {
  bool _loading = true;
  bool _error = false;

  Map<String, dynamic>? _sale;
  List<dynamic> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data =
          await SalesService.getSaleDetail(widget.saleId);

      setState(() {
        _sale = data['sale'];
        _payments = data['payments'];
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Detail'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? const Center(
                  child: Text('Failed to load sale'),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final customer = _sale!['customerId'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 CUSTOMER
          Text(
            customer?['name'] ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (customer?['mobile'] != null)
            Text(
              '📞 ${customer['mobile']}',
              style: const TextStyle(color: Colors.grey),
            ),

          const SizedBox(height: 20),

          // 📦 SALE SUMMARY
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _row('Category', _sale!['category']),
                  _row(
                      'Quantity',
                      _sale!['quantity'].toString()),
                  _row('Rate', '₹ ${_sale!['rate']}'),
                  _row(
                    'Total',
                    '₹ ${_sale!['total']}',
                  ),
                  const Divider(),
                  _row(
                    'Paid',
                    '₹ ${_sale!['paid']}',
                    AppColors.success,
                  ),
                  _row(
                    'Due',
                    '₹ ${_sale!['due']}',
                    AppColors.danger,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 🧾 PAYMENT HISTORY
          const Text(
            'Payment History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          _payments.isEmpty
              ? const Text(
                  'No payments yet',
                  style: TextStyle(color: Colors.grey),
                )
              : Column(
                  children: _payments.map<Widget>((p) {
                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          '₹ ${p['amount']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          _formatDate(p['createdAt']),
                        ),
                        trailing: const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ),
                    );
                  }).toList(),
                ),

          const SizedBox(height: 24),

          // 🔐 OWNER — ADD PAYMENT (OPTIONAL EXTENSION)
          FutureBuilder<bool>(
            future: RoleHelper.isOwner(),
            builder: (context, snapshot) {
              if (snapshot.data != true ||
                  _sale!['due'] <= 0) {
                return const SizedBox();
              }

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showPayDialog,
                  child: const Text('Add Payment'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPayDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Payment'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount =
                  int.tryParse(controller.text) ?? 0;

              if (amount <= 0) return;

              Navigator.pop(context);

              await SalesService.paySale(
                saleId: widget.saleId,
                amount: amount,
              );

              _loadDetail();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    final d = DateTime.parse(iso);
    return '${d.day}/${d.month}/${d.year}';
  }

  Widget _row(String label, String value,
      [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                const TextStyle(color: Colors.black54),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
