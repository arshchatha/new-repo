import 'package:sqflite/sqflite.dart';

class AddEquipmentColumnToUsers {
  static const String tableName = 'users';
  static const String columnName = 'equipment';

  Future<void> migrate(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final columnExists = columns.any((column) => column['name'] == columnName);
    if (!columnExists) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName TEXT');
    }
  }
}
