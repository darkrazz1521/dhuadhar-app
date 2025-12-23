import 'package:flutter/material.dart';
import '../services/production_service.dart';

class ProductionScreen extends StatefulWidget {
  final String type; // moulder / loader
  const ProductionScreen({super.key, required this.type});

  @override
  State<ProductionScreen> createState() =>
      _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  final String _date =
      DateTime.now().toIso8601String().substring(0, 10);
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data =
        await ProductionService.get(widget.type, _date);
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final payload = _items.map((e) {
      return {
        'labourId': e['labourId'],
        'quantity': e['quantity'],
        'ratePerThousand': e['ratePerThousand'],
      };
    }).toList();

    final ok = await ProductionService.save(
        widget.type, _date, payload);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('${widget.type} Production')),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final l = _items[i];
                return Card(
                  child: ListTile(
                    title: Text(l['name']),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType:
                                TextInputType.number,
                            decoration:
                                const InputDecoration(
                              labelText: 'Bricks',
                            ),
                            onChanged: (v) =>
                                l['quantity'] =
                                    int.tryParse(v) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            keyboardType:
                                TextInputType.number,
                            decoration:
                                const InputDecoration(
                              labelText: 'Rate / 1000',
                            ),
                            onChanged: (v) =>
                                l['ratePerThousand'] =
                                    int.tryParse(v) ?? 0,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '₹${l['totalAmount']}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
