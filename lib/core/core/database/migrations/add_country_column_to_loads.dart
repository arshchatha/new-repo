import 'package:sqflite/sqflite.dart';

class AddCountryColumnToLoads {
  Future<void> migrate(Database db) async {
    await db.execute('ALTER TABLE loads ADD COLUMN country TEXT');
  }
}
