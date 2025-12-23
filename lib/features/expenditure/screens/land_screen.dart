import 'package:flutter/material.dart';
import '../../../services/expenditure_service.dart';

class LandExpenseScreen extends StatefulWidget {
  const LandExpenseScreen({super.key});

  @override
  State<LandExpenseScreen> createState() => _LandExpenseScreenState();
}

class _LandExpenseScreenState extends State<LandExpenseScreen> {
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ExpenditureService.getLandExpenses();
      setState(() => _items = data);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _AddLandExpense()),
    ).then((v) {
      if (v == true) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Land Expense')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No land expenses'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final e = _items[i];
                    return Card(
                      child: ListTile(
                        title: Text(
                          '${e['landType'].toString().toUpperCase()} – ₹${e['amount']}',
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

class _AddLandExpense extends StatefulWidget {
  const _AddLandExpense();

  @override
  State<_AddLandExpense> createState() => _AddLandExpenseState();
}

class _AddLandExpenseState extends State<_AddLandExpense> {
  String _type = 'rented';
  final _month = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();

  Future<void> _save() async {
    final ok = await ExpenditureService.addLandExpense({
      'landType': _type,
      'month': _month.text,
      'amount': int.tryParse(_amount.text) ?? 0,
      'paidDate': DateTime.now().toIso8601String(),
      'notes': _notes.text,
    });
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Land Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField(
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: 'owned', child: Text('Owned')),
                DropdownMenuItem(value: 'rented', child: Text('Rented')),
              ],
              onChanged: (v) => setState(() => _type = v!),
              decoration: const InputDecoration(labelText: 'Land Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _month,
              decoration: const InputDecoration(
                labelText: 'Month (YYYY-MM)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
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
