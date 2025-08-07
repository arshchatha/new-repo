import 'package:sqflite/sqflite.dart';

class AddContactColumnsToLoads {
  Future<void> migrate(Database db) async {
    await db.execute('ALTER TABLE loads ADD COLUMN contactEmail TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN contactPhone TEXT');
  }
}
