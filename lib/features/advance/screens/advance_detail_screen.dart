import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/advance_service.dart';
import '../../../core/utils/role_helper.dart';
import '../../customer/screens/sale_detail_screen.dart'; // ✅ ADD

class AdvanceDetailScreen extends StatefulWidget {
  final String advanceId;

  const AdvanceDetailScreen({
    super.key,
    required this.advanceId,
  });

  @override
  State<AdvanceDetailScreen> createState() =>
      _AdvanceDetailScreenState();
}

class _AdvanceDetailScreenState
    extends State<AdvanceDetailScreen> {
  bool _loading = true;
  bool _error = false;

  Map<String, dynamic>? _advance;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data =
          await AdvanceService.getAdvanceDetail(widget.advanceId);

      setState(() {
        _advance = data;
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
        title: const Text('Advance Detail'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? const Center(
                  child: Text('Failed to load detail'),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final customer = _advance!['customerId'];
    final List sales = _advance!['sales'] ?? [];

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
          if (customer?['address'] != null)
            Text(
              '📍 ${customer['address']}',
              style: const TextStyle(color: Colors.grey),
            ),

          const SizedBox(height: 20),

          // 📦 ADVANCE SUMMARY
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _row('Category', _advance!['category']),
                  _row('Rate', '₹ ${_advance!['rate']}'),
                  _row(
                      'Ordered Qty',
                      _advance!['quantity'].toString()),
                  _row(
                    'Delivered',
                    _advance!['deliveredQuantity'].toString(),
                    AppColors.success,
                  ),
                  _row(
                    'Remaining Qty',
                    _advance!['remainingQuantity'].toString(),
                    AppColors.danger,
                  ),
                  const Divider(),
                  _row(
                    'Advance Paid',
                    '₹ ${_advance!['advance']}',
                    AppColors.success,
                  ),
                  _row(
                    'Remaining Amount',
                    '₹ ${_advance!['remaining']}',
                    AppColors.danger,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 🧾 LINKED SALES
          const Text(
            'Linked Sales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          sales.isEmpty
              ? const Text(
                  'No deliveries yet',
                  style: TextStyle(color: Colors.grey),
                )
              : Column(
                  children: sales.map<Widget>((s) {
                    return InkWell(
                      // ✅ TAP → SALE PAYMENT HISTORY
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SaleDetailScreen(
                              saleId: s['_id'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin:
                            const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            'Qty: ${s['quantity']}  |  ₹ ${s['total']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Paid: ₹ ${s['paid']}  |  Due: ₹ ${s['due']}',
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

          const SizedBox(height: 24),

          // 🔐 OWNER ACTION — FULL DELIVERY
          FutureBuilder<bool>(
            future: RoleHelper.isOwner(),
            builder: (context, snapshot) {
              if (snapshot.data != true ||
                  _advance!['status'] == 'delivered') {
                return const SizedBox();
              }

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _convertToFullSale,
                  child:
                      const Text('Convert Remaining to Sale'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _convertToFullSale() async {
    final ok =
        await AdvanceService.convertToSale(widget.advanceId);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Converted successfully')),
      );
      Navigator.pop(context, true);
    }
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
