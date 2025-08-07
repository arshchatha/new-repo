import 'package:sqflite/sqflite.dart';

Future<void> addLatitudeLongitudeColumnsToUsers(Database db) async {
  await db.execute('ALTER TABLE users ADD COLUMN latitude REAL');
  await db.execute('ALTER TABLE users ADD COLUMN longitude REAL');
}
