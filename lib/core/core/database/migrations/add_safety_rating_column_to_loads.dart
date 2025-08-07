import 'package:sqflite/sqflite.dart';

class AddSafetyRatingColumnToLoads {
  static const String tableName = 'loads';
  static const String columnName = 'safetyRating';

  Future<void> migrate(Database db) async {
    // Check if the column already exists to avoid duplicate addition
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final columnExists = columns.any((column) => column['name'] == columnName);

    if (!columnExists) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName TEXT');
    }
  }
}
