import 'package:flutter/material.dart';
import '../../../services/expenditure_service.dart';

class CoalExpenseScreen extends StatefulWidget {
  const CoalExpenseScreen({super.key});

  @override
  State<CoalExpenseScreen> createState() => _CoalExpenseScreenState();
}

class _CoalExpenseScreenState extends State<CoalExpenseScreen> {
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ExpenditureService.getCoalExpenses();
      setState(() => _items = data);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _AddCoalExpense()),
    ).then((v) {
      if (v == true) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coal Expense')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No coal expenses'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final e = _items[i];
                    return Card(
                      child: ListTile(
                        title: Text(
                          '₹${e['total']} (${e['quantity']} ton)',
                        ),
                        subtitle: Text(
                          '${e['supplier']} | ${e['date'].toString().substring(0,10)}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _AddCoalExpense extends StatefulWidget {
  const _AddCoalExpense();

  @override
  State<_AddCoalExpense> createState() => _AddCoalExpenseState();
}

class _AddCoalExpenseState extends State<_AddCoalExpense> {
  final _supplier = TextEditingController();
  final _qty = TextEditingController();
  final _rate = TextEditingController();
  final _notes = TextEditingController();

  Future<void> _save() async {
    final ok = await ExpenditureService.addCoalExpense({
      'date': DateTime.now().toIso8601String(),
      'supplier': _supplier.text,
      'quantity': double.tryParse(_qty.text) ?? 0,
      'rate': double.tryParse(_rate.text) ?? 0,
      'notes': _notes.text,
    });
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Coal Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _supplier,
              decoration: const InputDecoration(labelText: 'Supplier'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity (tons)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rate,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rate per ton'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
