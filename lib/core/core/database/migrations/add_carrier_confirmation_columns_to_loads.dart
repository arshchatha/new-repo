import 'package:sqflite/sqflite.dart';

class AddCarrierConfirmationColumnsToLoads {
  static Future<void> migrate(Database db) async {
    await db.execute('ALTER TABLE loads ADD COLUMN selectedBidId TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN brokerConfirmed INTEGER DEFAULT 0');
    await db.execute('ALTER TABLE loads ADD COLUMN carrierConfirmed INTEGER DEFAULT 0');
  }
}
