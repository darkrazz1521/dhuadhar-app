import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/sales_service.dart';
import '../../../core/utils/role_helper.dart';

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
    final prices = await SalesService.getPrices();
    prices.forEach((category, rate) {
      _controllers[category] =
          TextEditingController(text: rate.toString());
    });
    setState(() => _loading = false);
  }

  Future<void> _savePrice(String category) async {
    final rate = int.tryParse(_controllers[category]!.text);
    if (rate == null || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid rate')),
      );
      return;
    }

    final success =
        await SalesService.setPrice(category: category, rate: rate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Price updated' : 'Failed to update price',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔐 OWNER CHECK (UI LEVEL)
    return FutureBuilder<bool>(
      future: RoleHelper.isOwner(),
      builder: (context, snapshot) {
        // Loading role
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not owner → Access denied
        if (!snapshot.data!) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Access denied',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        // Owner → Allow access
        return Scaffold(
          appBar: AppBar(
            title: const Text('Set Prices (Owner)'),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
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
                                    decoration: const InputDecoration(
                                      labelText: 'Rate (₹ per brick)',
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
      },
    );
  }
}
