import 'package:sqflite/sqflite.dart';

/// Migration to add detailed location columns to loads table
/// This migration adds originCity, originCountry, originState, originPostalCode, originDescription,
/// destinationCity, destinationCountry, destinationState, destinationPostalCode, destinationDescription,
/// pickupTime, deliveryTime, and appointment columns to the loads table

class AddDetailedLocationColumnsToLoads {
  static const String migrationName = 'add_detailed_location_columns_to_loads';
  
  static Future<void> up(Database db) async {
    // Add origin location detail columns
    await db.execute('ALTER TABLE loads ADD COLUMN originCity TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN originCountry TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN originState TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN originPostalCode TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN originDescription TEXT');
    
    // Add destination location detail columns
    await db.execute('ALTER TABLE loads ADD COLUMN destinationCity TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN destinationCountry TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN destinationState TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN destinationPostalCode TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN destinationDescription TEXT');
    
    // Add time-related columns
    await db.execute('ALTER TABLE loads ADD COLUMN pickupTime TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN deliveryTime TEXT');
    await db.execute('ALTER TABLE loads ADD COLUMN appointment INTEGER DEFAULT 0');
  }
  
  static Future<void> down(Database db) async {
    // Remove origin location detail columns
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS originCity');
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS originCountry');
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS originState');
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS originPostalCode');
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS originDescription');
    
    // Remove destination location detail columns
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS destinationCity');
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS destinationCountry');
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS destinationState');
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS destinationPostalCode');
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS destinationDescription');
    
    // Remove time-related columns
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS pickupTime');
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS deliveryTime');
    await db.execute('ALTER TABLE loads DROP COLUMN IF EXISTS appointment');
  }
}
