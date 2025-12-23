import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;
  bool _error = false;

  late Map<String, dynamic> summary;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final data = await ReportService.getSummary();
      setState(() {
        summary = data;
        _loading = false;
      });
    } catch (e) {
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
        title: const Text('Reports'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? const Center(child: Text('Failed to load reports'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= SALES =================
                      _ReportCard(
                        title: 'Total Sales',
                        amount: summary['sales']['totalSales'],
                        color: AppColors.primary,
                      ),
                      _ReportCard(
                        title: 'Total Paid',
                        amount: summary['sales']['totalPaid'],
                        color: AppColors.success,
                      ),
                      _ReportCard(
                        title: 'Total Due',
                        amount: summary['sales']['totalDue'],
                        color: AppColors.danger,
                      ),

                      const SizedBox(height: 16),

                      // ================= EXPENDITURE =================
                      Card(
                        child: ListTile(
                          title: const Text('Total Expenditure'),
                          trailing: Text(
                            '₹ ${summary['expenditure']['total']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ================= LABOUR COST =================
                      Card(
                        child: ListTile(
                          title: const Text('Labour Cost'),
                          trailing: Text(
                            '₹ ${summary['labour']['total']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ================= PROFIT =================
                      Card(
                        child: ListTile(
                          title: const Text('Net Profit'),
                          trailing: Text(
                            '₹ ${summary['profit']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: summary['profit'] >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= EXPENSE BREAKDOWN =================
                      const Text(
                        'Expense Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Land'),
                              trailing: Text(
                                '₹ ${summary['expenditure']['land']}',
                              ),
                            ),
                            ListTile(
                              title: const Text('Coal'),
                              trailing: Text(
                                '₹ ${summary['expenditure']['coal']}',
                              ),
                            ),
                            ListTile(
                              title: const Text('Diesel'),
                              trailing: Text(
                                '₹ ${summary['expenditure']['diesel']}',
                              ),
                            ),
                            ListTile(
                              title: const Text('Electricity'),
                              trailing: Text(
                                '₹ ${summary['expenditure']['electricity']}',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= LABOUR BREAKDOWN =================
                      const Text(
                        'Labour Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Daily Labour'),
                              trailing: Text(
                                '₹ ${summary['labour']['daily']}',
                              ),
                            ),
                            ListTile(
                              title: const Text('Salary Labour'),
                              trailing: Text(
                                '₹ ${summary['labour']['salary']}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final int amount;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '₹ $amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
