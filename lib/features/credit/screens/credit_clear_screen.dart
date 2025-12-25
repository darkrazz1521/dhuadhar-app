import 'package:flutter/material.dart';

import '../../../services/sales_service.dart';
import '../../../services/credit_service.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/role_helper.dart';

class CreditClearScreen extends StatefulWidget {
  final String customerId;
  final int totalDue;

  const CreditClearScreen({
    super.key,
    required this.customerId,
    required this.totalDue,
  });

  @override
  State<CreditClearScreen> createState() => _CreditClearScreenState();
}

class _CreditClearScreenState extends State<CreditClearScreen> {
  bool _loading = true;
  bool _saving = false;

  List<Map<String, dynamic>> _sales = [];
  Map<String, dynamic>? _selectedSale;

  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPendingSales();
  }

  /* --------------------------------------------------
   * LOAD PENDING SALES (due > 0)
   * -------------------------------------------------- */
  Future<void> _loadPendingSales() async {
    try {
      final sales =
          await SalesService.getSalesByCustomer(widget.customerId);

      setState(() {
        _sales = sales
    .where((s) => s['due'] > 0)
    .map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s))
    .toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  /* --------------------------------------------------
   * PAY SELECTED SALE
   * -------------------------------------------------- */
  Future<void> _paySale() async {
    if (_selectedSale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a sale')),
      );
      return;
    }

    final amount = int.tryParse(_amountController.text) ?? 0;
    final int saleDue = _selectedSale!['due'];

    if (amount <= 0 || amount > saleDue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid amount')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await SalesService.paySale(
        saleId: _selectedSale!['_id'],
        amount: amount,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded')),
      );

      Navigator.pop(context, true);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save payment')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /* --------------------------------------------------
   * UI
   * -------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: RoleHelper.isOwner(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != true) {
          return const Scaffold(
            body: Center(child: Text('Access denied')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Clear Credit (Sale-wise)')),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOTAL CREDIT
                      Text(
                        'Total Due: ₹ ${widget.totalDue}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // SALE SELECT
                      const Text(
                        'Select Sale',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<Map<String, dynamic>>(
  value: _selectedSale,
  items: _sales.map<DropdownMenuItem<Map<String, dynamic>>>((s) {
    return DropdownMenuItem<Map<String, dynamic>>(
      value: s,
      child: Text(
        '${s['category']} | Due ₹${s['due']}',
      ),
    );
  }).toList(),
  onChanged: (v) {
    setState(() {
      _selectedSale = v;
      _amountController.clear();
    });
  },
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
  ),
),


                      const SizedBox(height: 16),

                      // AMOUNT
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount Received',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _paySale,
                          child: _saving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Save Payment'),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
