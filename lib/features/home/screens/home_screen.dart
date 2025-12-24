import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../core/utils/role_helper.dart';
import '../../../offline/sync/offline_sync_service.dart';
import '../../../services/dashboard_service.dart';
import '../../../core/widgets/badge.dart';
import '../../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _summary;
  bool _summaryError = false;

  @override
  void initState() {
    super.initState();

    OfflineSyncService.syncOfflineSales();

    DashboardService.getSummary()
        .then((data) {
          if (mounted) setState(() => _summary = data);
        })
        .catchError((_) {
          if (mounted) setState(() => _summaryError = true);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 0.6,
            color: Colors.black.withOpacity(0.08),
          ),
        ),
        title: const Text(
          'Dhuadhar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.black54),
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
        child: FutureBuilder<bool>(
          future: RoleHelper.isOwner(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final isOwner = snapshot.data ?? false;

            return ListView(
              children: [
                // ================= TODAY SNAPSHOT =================
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: AppColors.primary.withOpacity(0.06),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Today Sales',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '₹ —',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Today',
                          style: TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_summaryError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Dashboard summary unavailable',
                          style: TextStyle(fontSize: 12, color: Colors.amber),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
                Divider(color: Colors.black.withOpacity(0.08)),
                const SizedBox(height: 16),

                // ================= DAILY OPERATIONS =================
                const Text(
                  'Daily Operations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.05,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _HomeCard(
                      title: 'Sales Now',
                      icon: Icons.add_shopping_cart,
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamed(context, '/sales-now'),
                    ),
                    _HomeCard(
                      title: 'Advance Order',
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.success,
                      badge:
                          (_summary != null && _summary!['pendingAdvances'] > 0)
                          ? AppBadge(
                              text: _summary!['pendingAdvances'].toString(),
                              color: Colors.orange,
                            )
                          : null,
                      onTap: () => Navigator.pushNamed(context, '/advance'),
                    ),
                    _HomeCard(
                      title: 'Credit',
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.danger,
                      badge: (_summary != null && _summary!['creditDue'] > 0)
                          ? AppBadge(
                              text: '₹${_summary!['creditDue']}',
                              color: Colors.red,
                            )
                          : null,
                      onTap: () => Navigator.pushNamed(context, '/credit'),
                    ),
                    _HomeCard(
                      title: 'Sales Board',
                      icon: Icons.bar_chart_rounded,
                      color: Colors.blueGrey,
                      onTap: () => Navigator.pushNamed(context, '/sales-board'),
                    ),
                  ],
                ),

                if (isOwner) ...[
                  const SizedBox(height: 24),
                  Divider(color: Colors.black.withOpacity(0.08)),
                  const SizedBox(height: 16),

                  // ================= MANAGEMENT =================
                  const Text(
                    'Management',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.05,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _HomeCard(
                        title: 'Labour',
                        icon: Icons.groups_outlined,
                        color: Colors.teal,
                        badge:
                            (_summary != null &&
                                _summary!['salaryPendingCount'] > 0)
                            ? AppBadge(
                                text: '${_summary!['salaryPendingCount']}',
                                color: Colors.deepOrange,
                              )
                            : null,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.labourHome),
                      ),
                      _HomeCard(
                        title: 'Expenditure',
                        icon: Icons.account_balance_wallet_outlined,
                        color: Colors.deepOrange,
                        onTap: () =>
                            Navigator.pushNamed(context, '/expenditure'),
                      ),
                      _HomeCard(
                        title: 'Reports',
                        icon: Icons.receipt_long_outlined,
                        color: Colors.blueGrey,
                        onTap: () => Navigator.pushNamed(context, '/reports'),
                      ),
                      _HomeCard(
                        title: 'Set Prices',
                        icon: Icons.price_change_outlined,
                        color: AppColors.primary,
                        onTap: () => Navigator.pushNamed(context, '/prices'),
                      ),
                      _HomeCard(
                        title: 'Customers',
                        icon: Icons.people_outline,
                        color: Colors.indigo,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.customers),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ======================================================
// HOME CARD — FINAL FIXED VERSION
// ======================================================
class _HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? badge;

  const _HomeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            margin: EdgeInsets.zero, // 🔥 FIX 1
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: SizedBox.expand(
              // 🔥 FIX 2 (MOST IMPORTANT)
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(icon, size: 36, color: color),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (badge != null) Positioned(top: 8, right: 8, child: badge!),
        ],
      ),
    );
  }
}
