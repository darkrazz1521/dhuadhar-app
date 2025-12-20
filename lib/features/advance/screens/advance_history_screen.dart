import 'package:flutter/material.dart';
import '../../../services/advance_service.dart';
import '../../../theme/app_colors.dart';

class AdvanceHistoryScreen extends StatefulWidget {
  const AdvanceHistoryScreen({super.key});

  @override
  State<AdvanceHistoryScreen> createState() =>
      _AdvanceHistoryScreenState();
}

class _AdvanceHistoryScreenState
    extends State<AdvanceHistoryScreen> {
  bool _loading = true;
  bool _error = false;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await AdvanceService.getAdvances();
      setState(() {
        _history = data;
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
        title: const Text('Advance History'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? const Center(
                  child: Text('Failed to load history'),
                )
              : _history.isEmpty
                  ? const Center(
                      child: Text('No advance history'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final order = _history[index];

                        final bool delivered =
                            order['status'] == 'delivered';

                        return Card(
                          margin:
                              const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              order['customerId']['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Brick: ${order['category']}'),
                                Text(
                                    'Qty: ${order['quantity']}'),
                                Text(
                                    'Rate: ₹ ${order['rate']}'),
                                Text(
                                    'Date: ${_formatDate(order['createdAt'])}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total: ₹ ${order['total']}',
                                  style: const TextStyle(
                                      fontWeight:
                                          FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  delivered
                                      ? 'Delivered'
                                      : 'Pending',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: delivered
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatDate(String iso) {
    final date = DateTime.parse(iso);
    return '${date.day}/${date.month}/${date.year}';
  }
}
