import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/credit_service.dart';
import '../../../core/utils/role_helper.dart';

import 'credit_clear_screen.dart';
import 'credit_payment_history_screen.dart';

class CreditDetailScreen extends StatefulWidget {
  final String customerId;

  const CreditDetailScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<CreditDetailScreen> createState() => _CreditDetailScreenState();
}

class _CreditDetailScreenState extends State<CreditDetailScreen> {
  bool _loading = true;
  bool _error = false;

  int _totalDue = 0;
  Map<String, dynamic>? _customer; // 👈 populated customer

  @override
  void initState() {
    super.initState();
    _loadCreditDetail();
  }

  Future<void> _loadCreditDetail() async {
    try {
      final credit =
          await CreditService.getCreditByCustomer(widget.customerId);

      setState(() {
        _totalDue = credit['totalDue'];
        _customer = credit['customerId']; // populated
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
        title: const Text('Credit Detail'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? const Center(
                  child: Text('Failed to load credit detail'),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👤 CUSTOMER INFO
                      Text(
                        _customer?['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (_customer?['mobile'] != null)
                        Text(
                          _customer!['mobile'],
                          style: const TextStyle(color: Colors.grey),
                        ),

                      const SizedBox(height: 12),

                      // 💳 TOTAL DUE
                      Card(
                        color: AppColors.danger.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
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

                      const SizedBox(height: 24),

                      // 🔐 OWNER — CLEAR CREDIT
                      FutureBuilder<bool>(
                        future: RoleHelper.isOwner(),
                        builder: (context, snapshot) {
                          if (snapshot.data != true) {
                            return const SizedBox.shrink();
                          }

                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CreditClearScreen(
                                      customerId: widget.customerId,
                                      
                                      totalDue: _totalDue,
                                    ),
                                  ),
                                ).then((updated) {
                                  if (updated == true) {
                                    _loadCreditDetail();
                                  }
                                });
                              },
                              child: const Text('Clear Credit'),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // 📜 PAYMENT HISTORY
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CreditPaymentHistoryScreen(
                                  customerId: widget.customerId,
                                  
                                ),
                              ),
                            );
                          },
                          child:
                              const Text('View Payment History'),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
