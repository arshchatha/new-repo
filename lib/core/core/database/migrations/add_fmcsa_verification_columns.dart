import 'package:sqflite/sqflite.dart';

class AddFmcsaVerificationColumns {
  static Future<void> migrate(Database db) async {
    await db.execute('''
      ALTER TABLE users 
      ADD COLUMN is_fmcsa_verified INTEGER DEFAULT 0
    ''');

    await db.execute('''
      ALTER TABLE users 
      ADD COLUMN last_verification_date TEXT
    ''');

    await db.execute('''
      ALTER TABLE users 
      ADD COLUMN next_screenshot_due TEXT
    ''');

    await db.execute('''
      ALTER TABLE users 
      ADD COLUMN fmcsa_legal_name TEXT
    ''');

    await db.execute('''
      ALTER TABLE users 
      ADD COLUMN fmcsa_status TEXT
    ''');

    await db.execute('''
      ALTER TABLE users 
      ADD COLUMN power_units INTEGER
    ''');

    await db.execute('''
      ALTER TABLE users 
      ADD COLUMN drivers INTEGER
    ''');

    await db.execute('''
      ALTER TABLE users 
      ADD COLUMN mx_number TEXT
    ''');

    await db.execute('''
      ALTER TABLE users 
      ADD COLUMN ff_number TEXT
    ''');
  }
}
