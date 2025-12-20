import 'package:flutter/material.dart';

// ✅ App entry (session-based)
import '../core/app_entry.dart';

// Auth
import '../features/auth/screens/login_screen.dart';

// Home
import '../features/home/screens/home_screen.dart';

// Sales
import '../features/sales/screens/sales_board_screen.dart';
import '../features/sales/screens/sales_now_screen.dart';

// Credit
import '../features/credit/screens/credit_screen.dart';

// Advance
import '../features/advance/screens/advance_order_screen.dart';

// Reports
import '../features/reports/screens/reports_screen.dart';

// Pricing (Owner)
import '../features/pricing/screens/price_setting_screen.dart';

import '../features/advance/screens/advance_create_screen.dart';
import '../features/advance/screens/advance_history_screen.dart';



class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  static const String salesBoard = '/sales-board';
  static const String salesNow = '/sales-now';
  static const String credit = '/credit';
  static const String advance = '/advance';
  static const String reports = '/reports';
  static const String prices = '/prices';
  static const String advanceCreate = '/advance-create';
  static const String advanceHistory = '/advance-history';
  


  // Route map
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const AppEntry(), // ✅ FIXED
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),

    salesBoard: (context) => const SalesBoardScreen(),
    salesNow: (context) => const SalesNowScreen(),
    credit: (context) => const CreditScreen(),
    advance: (context) => const AdvanceOrderScreen(),
    reports: (context) => const ReportsScreen(),
    prices: (context) => const PriceSettingScreen(),
    advanceCreate: (context) => const AdvanceCreateScreen(),
    advanceHistory: (context) => const AdvanceHistoryScreen(),


  };
}
