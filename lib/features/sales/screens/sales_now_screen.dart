import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../theme/app_colors.dart';
import '../../../services/sales_service.dart';
import '../../../core/utils/network_helper.dart';

class SalesNowScreen extends StatefulWidget {
  const SalesNowScreen({super.key});

  @override
  State<SalesNowScreen> createState() => _SalesNowScreenState();
}

class _SalesNowScreenState extends State<SalesNowScreen> {
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();

  // 🔄 Backend-driven rates
  Map<String, int> _rates = {};

  String? _selectedCategory;
  bool _loadingPrices = true;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  // 📡 Load prices from backend
  void _loadPrices() async {
    final prices = await SalesService.getPrices();

    if (!mounted) return;

    setState(() {
      _rates = prices;
      _selectedCategory = _rates.isNotEmpty ? _rates.keys.first : null;
      _loadingPrices = false;
    });
  }

  int get _rate =>
      _selectedCategory != null ? _rates[_selectedCategory]! : 0;

  int get _quantity =>
      int.tryParse(_quantityController.text) ?? 0;

  int get _paid =>
      int.tryParse(_paidController.text) ?? 0;

  int get _total => _rate * _quantity;

  int get _due => (_total - _paid).clamp(0, _total);

  // 🧾 SAVE SALE (ONLINE / OFFLINE)
  void _saveSale() async {
    if (_selectedCategory == null) return;

    final isOnline = await NetworkHelper.isOnline();

    if (isOnline) {
      await SalesService.createSale(
        customerName: _customerController.text.trim(),
        category: _selectedCategory!,
        quantity: _quantity,
        paid: _paid,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale saved online')),
      );
    } else {
      final box = Hive.box('offline_sales');

      box.add({
        'customerName': _customerController.text.trim(),
        'category': _selectedCategory,
        'quantity': _quantity,
        'paid': _paid,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet. Sale saved offline')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Now'),
      ),
      body: _loadingPrices
          ? const Center(child: CircularProgressIndicator())
          : _rates.isEmpty
              ? const Center(
                  child: Text('No prices set by owner'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Customer name
                      TextField(
                        controller: _customerController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Category dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _rates.keys
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Brick Category',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Rate
                      _InfoRow(
                        label: 'Rate (₹ / brick)',
                        value: '₹ $_rate',
                      ),

                      const SizedBox(height: 16),

                      // Quantity
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Total
                      _InfoRow(
                        label: 'Total Amount',
                        value: '₹ $_total',
                        valueColor: AppColors.primary,
                      ),

                      const SizedBox(height: 16),

                      // Paid
                      TextField(
                        controller: _paidController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Paid Amount',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Due
                      _InfoRow(
                        label: 'Due Amount',
                        value: '₹ $_due',
                        valueColor: AppColors.danger,
                      ),

                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveSale,
                          child: const Text('Save Sale'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
