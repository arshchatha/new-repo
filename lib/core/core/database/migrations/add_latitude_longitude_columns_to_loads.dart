import 'package:sqflite/sqflite.dart';

class AddLatitudeLongitudeColumnsToLoads {
  Future<void> migrate(Database db) async {
    // Removed pickupLatitude and pickupLongitude columns as requested
    await db.execute("ALTER TABLE loads ADD COLUMN pickupLatitude REAL");
    await db.execute("ALTER TABLE loads ADD COLUMN pickupLongitude REAL");
    await db.execute("ALTER TABLE loads ADD COLUMN destinationLatitude REAL");
    await db.execute("ALTER TABLE loads ADD COLUMN destinationLongitude REAL");
    await db.execute("ALTER TABLE loads ADD COLUMN distance REAL");
    await db.execute("ALTER TABLE loads ADD COLUMN destinationDifference REAL");
    await db.execute("ALTER TABLE loads ADD COLUMN status TEXT");
  }
}
