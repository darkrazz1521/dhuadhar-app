import 'package:flutter/material.dart';
import '../../../services/expenditure_service.dart';

class DieselExpenseScreen extends StatefulWidget {
  const DieselExpenseScreen({super.key});

  @override
  State<DieselExpenseScreen> createState() =>
      _DieselExpenseScreenState();
}

class _DieselExpenseScreenState extends State<DieselExpenseScreen> {
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ExpenditureService.getDieselExpenses();
      setState(() => _items = data);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _AddDieselExpense()),
    ).then((v) {
      if (v == true) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diesel Expense')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No diesel expenses'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final e = _items[i];
                    return Card(
                      child: ListTile(
                        title: Text(
                          '₹${e['total']} (${e['litres']} L)',
                        ),
                        subtitle: Text(
                          '${e['purpose']} | ${e['date'].toString().substring(0,10)}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _AddDieselExpense extends StatefulWidget {
  const _AddDieselExpense();

  @override
  State<_AddDieselExpense> createState() => _AddDieselExpenseState();
}

class _AddDieselExpenseState extends State<_AddDieselExpense> {
  final _purpose = TextEditingController();
  final _litres = TextEditingController();
  final _rate = TextEditingController();
  final _notes = TextEditingController();

  Future<void> _save() async {
    final ok = await ExpenditureService.addDieselExpense({
      'date': DateTime.now().toIso8601String(),
      'purpose': _purpose.text,
      'litres': double.tryParse(_litres.text) ?? 0,
      'rate': double.tryParse(_rate.text) ?? 0,
      'notes': _notes.text,
    });
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Diesel Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _purpose,
              decoration: const InputDecoration(
                labelText: 'Purpose (tractor/truck/generator)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _litres,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Litres'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rate,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rate per litre'),
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
