import 'package:sqflite/sqflite.dart';

Future<void> addEquipmentColumn(Database db) async {
  await db.execute('ALTER TABLE loads ADD COLUMN equipment TEXT;');
}
