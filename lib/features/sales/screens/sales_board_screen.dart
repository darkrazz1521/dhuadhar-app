import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/sales_service.dart';

class SalesBoardScreen extends StatefulWidget {
  const SalesBoardScreen({super.key});

  @override
  State<SalesBoardScreen> createState() => _SalesBoardScreenState();
}

class _SalesBoardScreenState extends State<SalesBoardScreen> {
  bool _loading = true;
  bool _error = false;

  List<dynamic> _sales = [];
  int _totalToday = 0;

  @override
  void initState() {
    super.initState();
    _loadTodaySales();
  }

  Future<void> _loadTodaySales() async {
    try {
      final data = await SalesService.getTodaySales();

      int total = 0;
      for (final s in data) {
        total += (s['total'] as num).toInt();
      }

      setState(() {
        _sales = data;
        _totalToday = total;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  /// Group sales by category
  Map<String, Map<String, int>> _groupByCategory() {
    final Map<String, Map<String, int>> map = {};

    for (final s in _sales) {
      final String category = s['category'];
      final int qty = (s['quantity'] as num).toInt();
      final int total = (s['total'] as num).toInt();
      final int rate = (s['rate'] as num).toInt();

      if (!map.containsKey(category)) {
        map[category] = {
          'quantity': 0,
          'total': 0,
          'rate': rate,
        };
      }

      map[category]!['quantity'] =
          map[category]!['quantity']! + qty;
      map[category]!['total'] =
          map[category]!['total']! + total;
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByCategory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Board'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sales_now') {
                Navigator.pushNamed(context, '/sales-now')
                    .then((_) => _loadTodaySales());
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? const Center(child: Text('Failed to load sales'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 🔹 TOTAL TODAY
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Sales (Today)',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '₹ $_totalToday',
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

                      // 🔹 CATEGORY LIST
                      Expanded(
                        child: grouped.isEmpty
                            ? const Center(
                                child: Text('No sales today'),
                              )
                            : ListView(
                                children: grouped.entries.map((e) {
                                  return _CategoryTile(
                                    category: e.key,
                                    price: e.value['rate']!,
                                    quantity:
                                        e.value['quantity']!,
                                    total: e.value['total']!,
                                  );
                                }).toList(),
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
  final int total;

  const _CategoryTile({
    required this.category,
    required this.price,
    required this.quantity,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
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
