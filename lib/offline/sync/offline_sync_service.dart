import 'package:hive/hive.dart';
import '../../services/sales_service.dart';
import '../../core/utils/network_helper.dart';

class OfflineSyncService {

  static Future<void> syncOfflineSales() async {
    final isOnline = await NetworkHelper.isOnline();
    if (!isOnline) return;

    final box = Hive.box('offline_sales');
    final keys = box.keys.toList();

    for (final key in keys) {
      final data = box.get(key);

      try {
        await SalesService.createSale(
          customerName: data['customerName'],
          category: data['category'],
          quantity: data['quantity'],
          paid: data['paid'],
        );

        box.delete(key); // remove after sync
      } catch (_) {
        break; // stop if backend fails
      }
    }
  }
}
