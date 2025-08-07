import 'package:sqflite/sqflite.dart';

class AddDestinationDifferenceColumnToLoads {
  static Future<void> migrate(Database db) async {
    await db.execute('''
      ALTER TABLE loads ADD COLUMN destinationDifference TEXT;
    ''');
  }
}
