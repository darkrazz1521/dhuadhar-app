import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class SalesBoardScreen extends StatelessWidget {
  const SalesBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Board'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sales_now') {
                Navigator.pushNamed(context, '/sales-now');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'sales_now',
                child: Text('Sales Now'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Total sales card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Sales (Today)',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '₹ 0',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category list
            Expanded(
              child: ListView(
                children: const [
                  _CategoryTile(
                    category: 'Brick Category 1',
                    price: 12,
                    quantity: 0,
                  ),
                  _CategoryTile(
                    category: 'Brick Category 2',
                    price: 10,
                    quantity: 0,
                  ),
                  _CategoryTile(
                    category: 'Brick Category 3',
                    price: 8,
                    quantity: 0,
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

class _CategoryTile extends StatelessWidget {
  final String category;
  final int price;
  final int quantity;

  const _CategoryTile({
    required this.category,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final int total = price * quantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Rate: ₹$price / brick',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Qty: $quantity',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '₹ $total',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
