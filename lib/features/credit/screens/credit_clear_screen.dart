import 'package:flutter/material.dart';
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
  State<CreditClearScreen> createState() =>
      _CreditClearScreenState();
}

class _CreditClearScreenState extends State<CreditClearScreen> {
  final TextEditingController _amountController =
      TextEditingController();

  bool _saving = false;

  Future<void> _clearCredit() async {
    final amount = int.tryParse(_amountController.text) ?? 0;

    if (amount <= 0 || amount > widget.totalDue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid amount')),
      );
      return;
    }

    setState(() => _saving = true);

    final success = await CreditService.clearCredit(
      customerId: widget.customerId,
      amount: amount,
    );

    setState(() => _saving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credit updated')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update credit')),
      );
    }
  }

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

        if (!snapshot.data!) {
          return const Scaffold(
            body: Center(child: Text('Access denied')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Clear Credit'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Due',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹ ${widget.totalDue}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

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
                    onPressed: _saving ? null : _clearCredit,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
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
