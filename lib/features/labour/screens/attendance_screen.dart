import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class DailyAttendanceScreen extends StatefulWidget {
  const DailyAttendanceScreen({super.key});

  @override
  State<DailyAttendanceScreen> createState() =>
      _DailyAttendanceScreenState();
}

class _DailyAttendanceScreenState
    extends State<DailyAttendanceScreen> {
  final String _date =
      DateTime.now().toIso8601String().substring(0, 10);

  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await AttendanceService.getDaily(_date);
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final payload = _items.map((e) {
      return {
        'labourId': e['labourId'],
        'present': e['present'],
        'wage': e['wage'],
      };
    }).toList();

    final ok =
        await AttendanceService.save(_date, payload);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Attendance')),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final l = _items[i];
                return Card(
                  child: ListTile(
                    title: Text(l['name']),
                    leading: Checkbox(
                      value: l['present'],
                      onChanged: (v) {
                        setState(() {
                          l['present'] = v!;
                          if (!v) l['wage'] = 0;
                        });
                      },
                    ),
                    trailing: SizedBox(
                      width: 80,
                      child: TextField(
                        enabled: l['present'],
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            const InputDecoration(
                          hintText: '₹',
                        ),
                        onChanged: (v) {
                          l['wage'] =
                              int.tryParse(v) ?? 0;
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
