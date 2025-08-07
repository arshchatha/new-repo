import 'package:sqflite/sqflite.dart';

class AddLoadTypeColumnToLoads {
  Future<void> migrate(Database db) async {
    await db.execute('ALTER TABLE loads ADD COLUMN loadType TEXT');
  }
}
