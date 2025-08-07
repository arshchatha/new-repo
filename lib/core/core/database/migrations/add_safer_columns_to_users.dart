import 'package:sqflite/sqflite.dart';

class AddSaferColumnsToUsers {
  Future<void> migrate(Database db) async {
    await db.execute('ALTER TABLE users ADD COLUMN safer_legal_name TEXT');
    await db.execute('ALTER TABLE users ADD COLUMN safer_entity_type TEXT');
    await db.execute('ALTER TABLE users ADD COLUMN safer_status TEXT');
    await db.execute('ALTER TABLE users ADD COLUMN safer_address TEXT');
    await db.execute('ALTER TABLE users ADD COLUMN safer_usdot_number TEXT');
    await db.execute('ALTER TABLE users ADD COLUMN safer_mc_number TEXT');
    await db.execute('ALTER TABLE users ADD COLUMN safer_power_units INTEGER');
    await db.execute('ALTER TABLE users ADD COLUMN safer_drivers INTEGER');
    await db.execute('ALTER TABLE users ADD COLUMN safer_usdot_status TEXT');
    // Add more columns as needed for other safer snapshot fields
  }
}
