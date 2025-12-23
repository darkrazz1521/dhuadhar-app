import 'package:flutter/material.dart';
import '../services/labour_service.dart';
import './add_labour_screen.dart';

class LabourListScreen extends StatefulWidget {
  const LabourListScreen({super.key});

  @override
  State<LabourListScreen> createState() => _LabourListScreenState();
}

class _LabourListScreenState extends State<LabourListScreen> {
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await LabourService.getLabours();
      setState(() => _items = data);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddLabourScreen()),
    ).then((v) {
      if (v == true) _load();
    });
  }

  Future<void> _toggle(String id) async {
    await LabourService.toggleStatus(id);
    _load();
  }

  String _rateText(dynamic l) {
    if (l['category'] == 'daily') {
      return '₹ ${l['dailyRate']} / day';
    }
    if (l['category'] == 'salary') {
      return '₹ ${l['salary']} / month';
    }
    if (l['category'] == 'production') {
      return '₹ ${l['productionRate']} / unit';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Labour Master')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No labour added'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final l = _items[i];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '📞 ${l['mobile']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (l['workType'] != null)
                                    Text(
                                      '🧱 Work: ${l['workType']}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '👷 Type: ${l['category']}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '💰 ${_rateText(l)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ACTIVE TOGGLE
                            Switch(
                              value: l['isActive'] ?? true,
                              onChanged: (_) => _toggle(l['_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
