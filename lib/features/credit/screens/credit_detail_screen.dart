import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/credit_service.dart';
import 'credit_payment_history_screen.dart';

class CreditDetailScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CreditDetailScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<CreditDetailScreen> createState() => _CreditDetailScreenState();
}

class _CreditDetailScreenState extends State<CreditDetailScreen> {
  bool _loading = true;
  bool _error = false;
  int _totalDue = 0;

  @override
  void initState() {
    super.initState();
    _loadCreditDetail();
  }

  Future<void> _loadCreditDetail() async {
    try {
      final credit = await CreditService.getCreditByCustomer(widget.customerId);

      setState(() {
        _totalDue = credit['totalDue'];
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
      appBar: AppBar(title: const Text('Credit Detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
          ? const Center(child: Text('Failed to load credit detail'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    color: AppColors.danger.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Due',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹ $_totalDue',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ NEW BUTTON
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreditPaymentHistoryScreen(
                              customerId: widget.customerId,
                              customerName: widget.customerName,
                            ),
                          ),
                        );
                      },
                      child: const Text('View Payment History'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    '• This amount includes all pending dues\n'
                    '• Payments reduce this balance\n'
                    '• Sales and advance deliveries affect credit',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}
