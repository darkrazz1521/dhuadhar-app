import 'package:flutter/material.dart';
import '../../../services/sales_service.dart';

class PriceSettingScreen extends StatefulWidget {
  const PriceSettingScreen({super.key});

  @override
  State<PriceSettingScreen> createState() => _PriceSettingScreenState();
}

class _PriceSettingScreenState extends State<PriceSettingScreen> {
  bool _loading = true;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    try {
      final prices = await SalesService.getPrices();
      for (final entry in prices.entries) {
        _controllers[entry.key] =
            TextEditingController(text: entry.value.toString());
      }
    } catch (e) {
      // show error later
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _savePrice(String category) async {
    final rate = int.tryParse(_controllers[category]!.text) ?? 0;
    if (rate <= 0) return;

    await SalesService.setPrice(category: category, rate: rate);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Price updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Prices (Owner)'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _controllers.isEmpty
              ? const Center(child: Text('No categories found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _controllers.keys.map((category) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controllers[category],
                                    keyboardType: TextInputType.number,
                                    decoration:
                                        const InputDecoration(
                                      labelText: 'Rate',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () =>
                                      _savePrice(category),
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
