import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/sales_service.dart';
import '../../../core/widgets/customer_search_sheet.dart';

class SalesNowScreen extends StatefulWidget {
  const SalesNowScreen({super.key});

  @override
  State<SalesNowScreen> createState() => _SalesNowScreenState();
}

class _SalesNowScreenState extends State<SalesNowScreen> {
  Map<String, dynamic>? selectedCustomer;

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();

  Map<String, int> _rates = {};
  String? _selectedCategory;

  bool _loadingPrices = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  /* ---------------- LOAD PRICES ---------------- */
  Future<void> _loadPrices() async {
    final prices = await SalesService.getPrices();

    if (!mounted) return;

    setState(() {
      _rates = prices;

      // 🔥 CRITICAL FIX
      if (_rates.isNotEmpty) {
        _selectedCategory = _rates.keys.first;
      }

      _loadingPrices = false;
    });
  }

  /* ---------------- CALCULATIONS ---------------- */
  int get _rate {
    if (_selectedCategory == null) return 0;
    return _rates[_selectedCategory] ?? 0;
  }

  int get _quantity => int.tryParse(_quantityController.text) ?? 0;
  int get _paid => int.tryParse(_paidController.text) ?? 0;

  int get _total => _rate * _quantity;
  int get _due => (_total - _paid).clamp(0, _total);

  bool get _canSave =>
      selectedCustomer != null &&
      _selectedCategory != null &&
      _quantity > 0 &&
      !_saving;

  /* ---------------- RESET ---------------- */
  void _resetForm() {
    setState(() {
      selectedCustomer = null;
      _quantityController.clear();
      _paidController.clear();
    });
  }

  /* ---------------- SAVE SALE ---------------- */
  Future<void> _saveSale() async {
    if (!_canSave) return;

    setState(() => _saving = true);

    try {
      await SalesService.createSale(
        customerId: selectedCustomer!['_id'],
        category: _selectedCategory!,
        quantity: _quantity,
        paid: _paid,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale saved successfully')),
      );

      _resetForm();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save sale')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Now')),
      body: _loadingPrices
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /* -------- CUSTOMER -------- */
                  selectedCustomer == null
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => CustomerSearchSheet(
                                  onSelect: (c) {
                                    setState(() => selectedCustomer = c);
                                  },
                                ),
                              );
                            },
                            child: const Text('Select Customer'),
                          ),
                        )
                      : Card(
                          color: AppColors.primary.withOpacity(0.08),
                          child: ListTile(
                            title: Text(
                              selectedCustomer!['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(selectedCustomer!['mobile'] ?? ''),
                            trailing: TextButton(
                              onPressed: () =>
                                  setState(() => selectedCustomer = null),
                              child: const Text('Change'),
                            ),
                          ),
                        ),

                  const SizedBox(height: 16),

                  /* -------- CATEGORY -------- */
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _rates.keys.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCategory = v;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Brick Category',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _info('Rate', '₹ $_rate'),

                  const SizedBox(height: 16),

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
                  _info('Total', '₹ $_total', AppColors.primary),

                  const SizedBox(height: 16),

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
                  _info('Due', '₹ $_due', AppColors.danger),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canSave ? _saveSale : null,
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Sale'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _info(String label, String value, [Color? color]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
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
