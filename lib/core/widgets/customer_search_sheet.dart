import 'package:flutter/material.dart';

import '../../../services/customer_service.dart';
import 'add_customer_sheet.dart';

class CustomerSearchSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelect;

  const CustomerSearchSheet({
    super.key,
    required this.onSelect,
  });

  @override
  State<CustomerSearchSheet> createState() =>
      _CustomerSearchSheetState();
}

class _CustomerSearchSheetState extends State<CustomerSearchSheet> {
  final TextEditingController _search = TextEditingController();

  List<dynamic> _results = [];
  bool _loading = false;

  /* ---------------- SEARCH CUSTOMER ---------------- */
  Future<void> _doSearch(String q) async {
    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _loading = true);

    final data = await CustomerService.search(q);

    if (!mounted) return;

    setState(() {
      _results = data;
      _loading = false;
    });
  }

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /* -------- SEARCH INPUT -------- */
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Search customer',
                border: OutlineInputBorder(),
              ),
              onChanged: _doSearch,
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),

          /* -------- SEARCH RESULTS -------- */
          ListView.builder(
            shrinkWrap: true,
            itemCount: _results.length,
            itemBuilder: (_, i) {
              final c = _results[i];
              return ListTile(
                title: Text(c['name']),
                subtitle: Text(
                  '${c['mobile'] ?? ''} • ${c['address'] ?? ''}',
                ),
                onTap: () {
                  widget.onSelect(c);
                  Navigator.pop(context);
                },
              );
            },
          ),

          /* -------- ADD NEW CUSTOMER (KEY FEATURE) -------- */
          if (!_loading &&
              _results.isEmpty &&
              _search.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add New Customer'),
                  onPressed: () {
                    Navigator.pop(context);

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => AddCustomerSheet(
                        initialName: _search.text,
                        onCreated: (customer) {
                          widget.onSelect(customer);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
