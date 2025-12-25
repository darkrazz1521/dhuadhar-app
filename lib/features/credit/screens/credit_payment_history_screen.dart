import 'package:flutter/material.dart';

import '../../../services/credit_service.dart';
import '../../../theme/app_colors.dart';

class CreditPaymentHistoryScreen extends StatefulWidget {
  final String customerId;

  const CreditPaymentHistoryScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<CreditPaymentHistoryScreen> createState() =>
      _CreditPaymentHistoryScreenState();
}

class _CreditPaymentHistoryScreenState
    extends State<CreditPaymentHistoryScreen> {
  bool _loading = true;
  bool _error = false;
  List<dynamic> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final data =
          await CreditService.getPaymentHistory(widget.customerId);

      if (!mounted) return;

      setState(() {
        _payments = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
        title: const Text('Payment History'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? const Center(
                  child: Text('Failed to load payment history'),
                )
              : _payments.isEmpty
                  ? const Center(
                      child: Text('No payments found'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _payments.length,
                      itemBuilder: (context, index) {
                        final payment = _payments[index];

                        final amount = payment['amount'] ?? 0;
                        final createdAt =
                            payment['createdAt'] as String?;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(
                              Icons.payments,
                              color: AppColors.success,
                            ),
                            title: Text(
                              '₹ $amount',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: createdAt != null
                                ? Text(_formatDate(createdAt))
                                : const Text('—'),
                            trailing: const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}
