import 'package:flutter/material.dart';
import '../../../services/customer_service.dart';

class AddCustomerSheet extends StatefulWidget {
  final String initialName;
  final Function(Map<String, dynamic>) onCreated;

  const AddCustomerSheet({
    super.key,
    required this.initialName,
    required this.onCreated,
  });

  @override
  State<AddCustomerSheet> createState() =>
      _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<AddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  final _mobile = TextEditingController();
  final _address = TextEditingController();

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final customer = await CustomerService.create({
        'name': _name.text.trim(),
        'mobile': _mobile.text.trim(),
        'address': _address.text.trim(),
      });

      widget.onCreated(customer);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = 'Mobile already exists or server error';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add New Customer',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _name,
                decoration:
                    const InputDecoration(labelText: 'Customer Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: _mobile,
                decoration:
                    const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.length < 10 ? 'Invalid mobile' : null,
              ),

              TextFormField(
                controller: _address,
                decoration:
                    const InputDecoration(labelText: 'Village / Address'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('Save & Select'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
