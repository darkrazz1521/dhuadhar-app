import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/sales_service.dart';
import '../../../services/advance_service.dart';
import '../../../core/widgets/customer_search_sheet.dart';

class AdvanceCreateScreen extends StatefulWidget {
  const AdvanceCreateScreen({super.key});

  @override
  State<AdvanceCreateScreen> createState() =>
      _AdvanceCreateScreenState();
}

class _AdvanceCreateScreenState
    extends State<AdvanceCreateScreen> {
  // ✅ Selected customer
  Map<String, dynamic>? selectedCustomer;

  final TextEditingController _quantityController =
      TextEditingController();
  final TextEditingController _advanceController =
      TextEditingController();

  Map<String, int> _rates = {};
  String? _selectedCategory;
  bool _loading = true;
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
      _selectedCategory =
          prices.isNotEmpty ? prices.keys.first : null;
      _loading = false;
    });
  }

  int get _quantity =>
      int.tryParse(_quantityController.text) ?? 0;

  int get _advance =>
      int.tryParse(_advanceController.text) ?? 0;

  int get _rate =>
      _selectedCategory != null ? _rates[_selectedCategory]! : 0;

  int get _total => _rate * _quantity;

  int get _remaining =>
      (_total - _advance).clamp(0, _total);

  bool get _canSave =>
      selectedCustomer != null &&
      _selectedCategory != null &&
      _quantity > 0 &&
      !_saving;

  /* ---------------- RESET FORM ---------------- */
  void _resetForm() {
    setState(() {
      selectedCustomer = null;
      _quantityController.clear();
      _advanceController.clear();
    });
  }

  /* ---------------- SAVE ADVANCE ---------------- */
  Future<void> _saveAdvance() async {
    if (!_canSave) return;

    setState(() => _saving = true);

    try {
      final success = await AdvanceService.createAdvance(
        customerId: selectedCustomer!['_id'],
        category: _selectedCategory!,
        quantity: _quantity,
        advance: _advance,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Advance order created')),
        );

        _resetForm();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to create advance')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /* ---------------- UI ---------------- */
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
                  /* -------- CUSTOMER -------- */
                  selectedCustomer == null
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) =>
                                    CustomerSearchSheet(
                                  onSelect: (c) {
                                    setState(() =>
                                        selectedCustomer = c);
                                  },
                                ),
                              );
                            },
                            child:
                                const Text('Select Customer'),
                          ),
                        )
                      : Card(
                          color: AppColors.primary
                              .withOpacity(0.08),
                          child: ListTile(
                            title: Text(
                              selectedCustomer!['name'],
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (selectedCustomer!['mobile'] !=
                                    null)
                                  Text(
                                      '📞 ${selectedCustomer!['mobile']}'),
                                if (selectedCustomer!['address'] !=
                                    null)
                                  Text(
                                      '📍 ${selectedCustomer!['address']}'),
                              ],
                            ),
                            trailing: TextButton(
                              onPressed: () => setState(
                                  () => selectedCustomer = null),
                              child: const Text('Change'),
                            ),
                          ),
                        ),

                  const SizedBox(height: 16),

                  /* -------- CATEGORY -------- */
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    items: _rates.keys
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCategory = v),
                    decoration: const InputDecoration(
                      labelText: 'Brick Category',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _infoRow('Rate', '₹ $_rate'),

                  const SizedBox(height: 16),

                  /* -------- QUANTITY -------- */
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
                  _infoRow(
                    'Total',
                    '₹ $_total',
                    color: AppColors.primary,
                  ),

                  const SizedBox(height: 16),

                  /* -------- ADVANCE -------- */
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
                  _infoRow(
                    'Remaining',
                    '₹ $_remaining',
                    color: AppColors.danger,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canSave ? _saveAdvance : null,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Advance'),
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
