import 'package:sqflite/sqflite.dart';

Future<void> addDistanceRadiusLimitColumnToUsers(Database db) async {
  await db.execute('ALTER TABLE users ADD COLUMN distanceRadiusLimit INTEGER');
}
