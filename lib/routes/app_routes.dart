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
import '../features/credit/screens/credit_detail_screen.dart';
import '../features/credit/screens/credit_payment_history_screen.dart';

// Advance
import '../features/advance/screens/advance_order_screen.dart';
import '../features/advance/screens/advance_create_screen.dart';
import '../features/advance/screens/advance_history_screen.dart';

// Reports
import '../features/reports/screens/reports_screen.dart';

// Pricing (Owner)
import '../features/pricing/screens/price_setting_screen.dart';

// Expenditure 
import '../features/expenditure/screens/expenditure_board_screen.dart';
import '../features/expenditure/screens/land_screen.dart';
import '../features/expenditure/screens/coal_screen.dart';
import '../features/expenditure/screens/diesel_screen.dart';
import '../features/expenditure/screens/electricity_screen.dart';

import '../features/labour/screens/labour_list_screen.dart';
import '../features/labour/screens/attendance_screen.dart';
import '../features/labour/screens/salary_screen.dart';
import '../features/labour/screens/labour_board_screen.dart';
import '../features/labour/screens/production_screen.dart';
import '../features/labour/screens/labour_home_screen.dart';

import '../features/customer/screens/customer_list_screen.dart';









class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  static const String salesBoard = '/sales-board';
  static const String salesNow = '/sales-now';

  static const String credit = '/credit';
  static const String creditDetail = '/credit-detail';
  static const String creditPayments = '/credit-payments';

  static const String advance = '/advance';
  static const String advanceCreate = '/advance-create';
  static const String advanceHistory = '/advance-history';

  static const String reports = '/reports';
  static const String prices = '/prices';

  // 🔥 Expenditure
  static const String expenditure = '/expenditure';
  static const String landExpense = '/land-expense';
  static const String coalExpense = '/coal-expense';
  static const String dieselExpense = '/diesel-expense';
  static const String electricityExpense = '/electricity-expense';

  static const String labour = '/labour';
  static const String attendance = '/attendance';
  static const String salary = '/salary';
  static const String labourBoard = '/labour-board';
  static const String moulder = '/moulder';
static const String loader = '/loader';
static const String labourHome = '/labour-home';

static const String customers = '/customers';
static const String customerDetail = '/customer-detail';









  // Route map
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const AppEntry(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),

    // Sales
    salesBoard: (context) => const SalesBoardScreen(),
    salesNow: (context) => const SalesNowScreen(),

    // Credit
    credit: (context) => const CreditScreen(),
    creditDetail: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      return CreditDetailScreen(
        customerId: args['customerId'],
      );
    },
    creditPayments: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      return CreditPaymentHistoryScreen(
        customerId: args['customerId'],
      );
    },

    // Advance
    advance: (context) => const AdvanceOrderScreen(),
    advanceCreate: (context) => const AdvanceCreateScreen(),
    advanceHistory: (context) => const AdvanceHistoryScreen(),

    // Reports & Pricing
    reports: (context) => const ReportsScreen(),
    prices: (context) => const PriceSettingScreen(),

    // 🔥 Expenditure 
    expenditure: (context) => const ExpenditureBoardScreen(),
    landExpense: (context) => const LandExpenseScreen(),
    coalExpense: (context) => const CoalExpenseScreen(),
    dieselExpense: (context) => const DieselExpenseScreen(),
    electricityExpense: (context) => const ElectricityExpenseScreen(),

    labour: (context) => const LabourListScreen(),
    attendance: (context) => const DailyAttendanceScreen(),
    salary: (context) => const SalaryScreen(),
    labourBoard: (context) => const LabourBoardScreen(),
    moulder: (context) => const ProductionScreen(type: 'moulder'),
loader: (context) => const ProductionScreen(type: 'loader'),
labourHome: (context) => const LabourHomeScreen(),

customers: (context) => const CustomerListScreen(),







  };
}
