import 'package:sqflite/sqflite.dart';

Future<void> addIsCarrierPostColumnToLoads(Database db) async {
  await db.execute('ALTER TABLE loads ADD COLUMN isCarrierPost INTEGER DEFAULT 0');
}
