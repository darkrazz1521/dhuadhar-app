import 'package:flutter/material.dart';

class ExpenditureBoardScreen extends StatelessWidget {
  const ExpenditureBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenditure'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _ExpenseCard(
              title: 'Land',
              icon: Icons.landscape,
              color: Colors.brown,
              onTap: () {
                Navigator.pushNamed(context, '/land-expense');
              },
            ),
            _ExpenseCard(
              title: 'Coal',
              icon: Icons.local_fire_department,
              color: Colors.deepOrange,
              onTap: () {
                Navigator.pushNamed(context, '/coal-expense');
              },
            ),
            _ExpenseCard(
              title: 'Diesel',
              icon: Icons.local_gas_station,
              color: Colors.blueGrey,
              onTap: () {
                Navigator.pushNamed(context, '/diesel-expense');
              },
            ),
            _ExpenseCard(
              title: 'Electricity',
              icon: Icons.flash_on,
              color: Colors.amber,
              onTap: () {
                Navigator.pushNamed(context, '/electricity-expense');
              },
            ),
            _ExpenseCard(
              title: 'Maintenance',
              icon: Icons.build,
              color: Colors.grey,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Maintenance module coming soon'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ExpenseCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
