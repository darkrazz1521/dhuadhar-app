import 'package:flutter/material.dart';
import '../services/labour_board_service.dart';

class LabourBoardScreen extends StatefulWidget {
  const LabourBoardScreen({super.key});

  @override
  State<LabourBoardScreen> createState() =>
      _LabourBoardScreenState();
}

class _LabourBoardScreenState extends State<LabourBoardScreen> {
  bool _loading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await LabourBoardService.getSummary();
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Widget _card(String title, String value,
      {Color? color}) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Labour Board')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  'Total Active Labour',
                  _data['totalLabour'].toString(),
                ),
                _card(
                  'Daily Wages (This Month)',
                  '₹ ${_data['dailyWages']}',
                  color: Colors.orange,
                ),
                _card(
                  'Salary Paid',
                  '₹ ${_data['salary']['paid']}',
                  color: Colors.green,
                ),
                _card(
                  'Salary Pending',
                  '₹ ${_data['salary']['pending']}',
                  color: Colors.red,
                ),
                const Divider(),
                _card(
                  'Total Labour Cost',
                  '₹ ${_data['totalLabourCost']}',
                  color: Colors.blue,
                ),
              ],
            ),
    );
  }
}
