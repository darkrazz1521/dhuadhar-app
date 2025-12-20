import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../core/utils/role_helper.dart';
import '../../../offline/sync/offline_sync_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // 🔄 AUTO SYNC OFFLINE SALES ON APP OPEN
    OfflineSyncService.syncOfflineSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhuadhar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Sales summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today Sales',
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

            const SizedBox(height: 20),

            // 🔐 Role-based action buttons
            Expanded(
              child: FutureBuilder<bool>(
                future: RoleHelper.isOwner(),
                builder: (context, snapshot) {
                  final isOwner = snapshot.data ?? false;

                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _HomeCard(
                        title: 'Sales Board',
                        icon: Icons.bar_chart,
                        color: AppColors.primary,
                        onTap: () =>
                            Navigator.pushNamed(context, '/sales-board'),
                      ),
                      _HomeCard(
                        title: 'Sales Now',
                        icon: Icons.add_shopping_cart,
                        color: AppColors.secondary,
                        onTap: () =>
                            Navigator.pushNamed(context, '/sales-now'),
                      ),
                      _HomeCard(
                        title: 'Credit',
                        icon: Icons.account_balance_wallet,
                        color: AppColors.danger,
                        onTap: () =>
                            Navigator.pushNamed(context, '/credit'),
                      ),
                      _HomeCard(
                        title: 'Advance Order',
                        icon: Icons.inventory,
                        color: AppColors.success,
                        onTap: () =>
                            Navigator.pushNamed(context, '/advance'),
                      ),

                      // 👑 OWNER ONLY
                      if (isOwner)
                        _HomeCard(
                          title: 'Reports',
                          icon: Icons.receipt_long,
                          color: Colors.blueGrey,
                          onTap: () =>
                              Navigator.pushNamed(context, '/reports'),
                        ),

                      if (isOwner)
                        _HomeCard(
                          title: 'Set Prices',
                          icon: Icons.price_change,
                          color: AppColors.primary,
                          onTap: () =>
                              Navigator.pushNamed(context, '/prices'),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
