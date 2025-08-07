import 'package:sembast/sembast.dart';

Future<void> migrationAddOcrFieldsToInvoices(Database db) async {
  final store = intMapStoreFactory.store('invoices');

  final records = await store.find(db);
  for (var record in records) {
    final data = Map<String, dynamic>.from(record.value);
    if (!data.containsKey('ocrVerified')) {
      data['ocrVerified'] = false;
    }
    if (!data.containsKey('ocrText')) {
      data['ocrText'] = '';
    }
    await store.record(record.key).put(db, data);
  }
}
