import 'package:hive/hive.dart';

import '../../services/sales_service.dart';
import '../../core/utils/network_helper.dart';

class OfflineSyncService {
  /* --------------------------------------------------------
   * SYNC OFFLINE SALES (customerId based)
   * ------------------------------------------------------ */
  static Future<void> syncOfflineSales() async {
    final isOnline = await NetworkHelper.isOnline();
    if (!isOnline) return;

    final box = Hive.box('offline_sales');
    final keys = box.keys.toList();

    for (final key in keys) {
      final data = box.get(key);

      try {
        await SalesService.createSale(
          customerId: data['customerId'],
          category: data['category'],
          quantity: data['quantity'],
          paid: data['paid'],
        );

        // ✅ remove only after successful sync
        await box.delete(key);
      } catch (e) {
        // ❌ stop syncing if backend fails (retry later)
        break;
      }
    }
  }
}
