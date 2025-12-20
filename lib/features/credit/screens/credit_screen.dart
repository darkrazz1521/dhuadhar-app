import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/credit_service.dart';
import 'credit_detail_screen.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  bool _loading = true;
  bool _error = false;
  List<dynamic> _credits = [];

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    try {
      final data = await CreditService.getCredits();
      setState(() {
        _credits = data;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CreditSearchDelegate(_credits),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? const Center(child: Text('Failed to load credit'))
              : _credits.isEmpty
                  ? const Center(child: Text('No credit records'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _credits.length,
                      itemBuilder: (context, index) {
                        final credit = _credits[index];
                        final int due = credit['totalDue'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              credit['customerId']['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Text(
                              '₹ $due',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: due > 0
                                    ? AppColors.danger
                                    : AppColors.success,
                              ),
                            ),

                            // ✅ UPDATED NAVIGATION
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreditDetailScreen(
                                    customerId:
                                        credit['customerId']['_id'],
                                    customerName:
                                        credit['customerId']['name'],
                                  ),
                                ),
                              );

                              // refresh after return
                              _loadCredits();
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

class CreditSearchDelegate extends SearchDelegate {
  final List<dynamic> credits;

  CreditSearchDelegate(this.credits);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = credits.where((c) {
      return c['customerId']['name']
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = credits.where((c) {
      return c['customerId']['name']
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    return _buildList(results);
  }

  Widget _buildList(List<dynamic> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final credit = list[index];
        return ListTile(
          title: Text(credit['customerId']['name']),
          trailing: Text('₹ ${credit['totalDue']}'),
        );
      },
    );
  }
}
