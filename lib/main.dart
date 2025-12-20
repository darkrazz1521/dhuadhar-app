import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 📦 INIT HIVE
  await Hive.initFlutter();
  await Hive.openBox('offline_sales');

  runApp(const DhuadharApp());
}

class DhuadharApp extends StatelessWidget {
  const DhuadharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dhuadhar',
      theme: AppTheme.lightTheme,

      // ✅ ROUTE-BASED ENTRY (CENTRALIZED)
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
