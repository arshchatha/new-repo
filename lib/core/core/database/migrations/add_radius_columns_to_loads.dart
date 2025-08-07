import 'package:sqflite/sqflite.dart';

Future<void> addRadiusColumnsToLoads(Database db) async {
  await db.execute('ALTER TABLE loads ADD COLUMN originRadius INTEGER');
  await db.execute('ALTER TABLE loads ADD COLUMN destinationRadius INTEGER');
}
