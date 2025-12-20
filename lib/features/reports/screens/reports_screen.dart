import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/sales_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;
  bool _error = false;

  int totalSales = 0;
  int totalPaid = 0;
  int totalDue = 0;
  int totalAdvance = 0;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final data = await SalesService.getReportSummary();
      setState(() {
        totalSales = data['totalSales'] ?? 0;
        totalPaid = data['totalPaid'] ?? 0;
        totalDue = data['totalDue'] ?? 0;
        totalAdvance = data['totalAdvance'] ?? 0;
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
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _ReportCard(
                        title: 'Total Sales',
                        amount: totalSales,
                        color: AppColors.primary,
                      ),
                      _ReportCard(
                        title: 'Total Paid',
                        amount: totalPaid,
                        color: AppColors.success,
                      ),
                      _ReportCard(
                        title: 'Total Due',
                        amount: totalDue,
                        color: AppColors.danger,
                      ),
                      _ReportCard(
                        title: 'Advance Amount',
                        amount: totalAdvance,
                        color: AppColors.secondary,
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
