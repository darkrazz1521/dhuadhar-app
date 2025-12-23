import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class LabourHomeScreen extends StatelessWidget {
  const LabourHomeScreen({super.key});

  Widget _tile(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Labour')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            context,
            'Labour Master',
            Icons.groups,
            AppRoutes.labour,
          ),
          _tile(
            context,
            'Daily Labour',
            Icons.calendar_today,
            AppRoutes.attendance,
          ),
          _tile(
            context,
            'Production – Moulder',
            Icons.factory,
            AppRoutes.moulder,
          ),
          _tile(
            context,
            'Production – Loader',
            Icons.local_shipping,
            AppRoutes.loader,
          ),
          _tile(
            context,
            'Salary Labour',
            Icons.payments,
            AppRoutes.salary,
          ),
          _tile(
            context,
            'Labour Board',
            Icons.bar_chart,
            AppRoutes.labourBoard,
          ),
        ],
      ),
    );
  }
}
