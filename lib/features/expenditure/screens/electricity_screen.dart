import 'package:flutter/material.dart';
import '../../../services/expenditure_service.dart';

class ElectricityExpenseScreen extends StatefulWidget {
  const ElectricityExpenseScreen({super.key});

  @override
  State<ElectricityExpenseScreen> createState() =>
      _ElectricityExpenseScreenState();
}

class _ElectricityExpenseScreenState
    extends State<ElectricityExpenseScreen> {
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data =
          await ExpenditureService.getElectricityExpenses();
      setState(() => _items = data);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _AddElectricityExpense(),
      ),
    ).then((v) {
      if (v == true) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Electricity Expense')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('No electricity expenses'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final e = _items[i];
                    return Card(
                      child: ListTile(
                        title: Text(
                          '₹${e['amount']} | ${e['units']} units',
                        ),
                        subtitle: Text(
                          'Month: ${e['month']} | Paid: ${e['paidDate'].toString().substring(0,10)}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _AddElectricityExpense extends StatefulWidget {
  const _AddElectricityExpense();

  @override
  State<_AddElectricityExpense> createState() =>
      _AddElectricityExpenseState();
}

class _AddElectricityExpenseState
    extends State<_AddElectricityExpense> {
  final _month = TextEditingController();
  final _units = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();

  Future<void> _save() async {
    final ok =
        await ExpenditureService.addElectricityExpense({
      'month': _month.text,
      'units': int.tryParse(_units.text) ?? 0,
      'amount': int.tryParse(_amount.text) ?? 0,
      'paidDate': DateTime.now().toIso8601String(),
      'notes': _notes.text,
    });
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Electricity Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _month,
              decoration: const InputDecoration(
                labelText: 'Bill Month (YYYY-MM)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _units,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Units'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration:
                  const InputDecoration(labelText: 'Notes'),
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
