import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/sales_service.dart';
import '../../../services/advance_service.dart';

class AdvanceCreateScreen extends StatefulWidget {
  const AdvanceCreateScreen({super.key});

  @override
  State<AdvanceCreateScreen> createState() => _AdvanceCreateScreenState();
}

class _AdvanceCreateScreenState extends State<AdvanceCreateScreen> {
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();

  Map<String, int> _rates = {};
  String? _selectedCategory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final prices = await SalesService.getPrices();
    setState(() {
      _rates = prices;
      _selectedCategory = prices.keys.first;
      _loading = false;
    });
  }

  int get _quantity =>
      int.tryParse(_quantityController.text) ?? 0;

  int get _advance =>
      int.tryParse(_advanceController.text) ?? 0;

  int get _rate => _rates[_selectedCategory] ?? 0;

  int get _total => _rate * _quantity;

  int get _remaining =>
      (_total - _advance).clamp(0, _total);

  Future<void> _saveAdvance() async {
    if (_customerController.text.isEmpty || _quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all required fields')),
      );
      return;
    }

    final success = await AdvanceService.createAdvance(
      customerName: _customerController.text,
      category: _selectedCategory!,
      quantity: _quantity,
      advance: _advance,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advance order created')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create advance')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Advance Order'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Customer
                  TextField(
                    controller: _customerController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category
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
                  _infoRow('Rate', '₹ $_rate'),

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
                  _infoRow(
                    'Total',
                    '₹ $_total',
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 16),

                  // Advance
                  TextField(
                    controller: _advanceController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Advance Paid',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Remaining
                  _infoRow(
                    'Remaining',
                    '₹ $_remaining',
                    color: AppColors.danger,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveAdvance,
                      child: const Text('Save Advance'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
