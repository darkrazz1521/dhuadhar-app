import 'package:flutter/material.dart';
import '../services/labour_service.dart';

class AddLabourScreen extends StatefulWidget {
  const AddLabourScreen({super.key});

  @override
  State<AddLabourScreen> createState() => _AddLabourScreenState();
}

class _AddLabourScreenState extends State<AddLabourScreen> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _rate = TextEditingController();

  String _category = 'daily';
  String _workType = 'General';

  final List<String> _workTypes = [
    'General',
    'Moulder',
    'Loader',
    'Driver',
    'Cook',
    'Munshi',
  ];

  Future<void> _save() async {
    if (_name.text.isEmpty || _mobile.text.isEmpty) {
      _toast('Name & Mobile required');
      return;
    }

    final Map<String, dynamic> payload = {
  'name': _name.text.trim(),
  'mobile': _mobile.text.trim(),
  'category': _category,
  'workType': _workType,
};


    if (_category == 'daily') {
      payload['dailyRate'] = int.tryParse(_rate.text) ?? 0;
    }

    if (_category == 'salary') {
      payload['monthlySalary'] = int.tryParse(_rate.text) ?? 0;
    }

    if (_category == 'production') {
      payload['productionRate'] = int.tryParse(_rate.text) ?? 0;
    }

    final ok = await LabourService.addLabour(payload);
    if (ok && mounted) Navigator.pop(context, true);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String get _rateLabel {
    switch (_category) {
      case 'daily':
        return 'Daily Rate';
      case 'salary':
        return 'Monthly Salary';
      case 'production':
        return 'Production Rate';
      default:
        return 'Rate';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Labour')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // NAME
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),

            const SizedBox(height: 12),

            // MOBILE
            TextField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile'),
            ),

            const SizedBox(height: 12),

            // CATEGORY
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration:
                  const InputDecoration(labelText: 'Labour Category'),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'salary', child: Text('Salary')),
                DropdownMenuItem(
                    value: 'production', child: Text('Production')),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),

            const SizedBox(height: 12),

            // WORK TYPE (FIXED OPTIONS)
            DropdownButtonFormField<String>(
              initialValue: _workType,
              decoration:
                  const InputDecoration(labelText: 'Work Type'),
              items: _workTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _workType = v!),
            ),

            const SizedBox(height: 12),

            // RATE / SALARY
            TextField(
              controller: _rate,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: _rateLabel),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Labour'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
