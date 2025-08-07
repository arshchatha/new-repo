    import 'package:sqflite/sqflite.dart';
    import 'package:path/path.dart';

    class DatabaseHelper {
      static final DatabaseHelper _instance = DatabaseHelper._internal();
      factory DatabaseHelper() => _instance;

      static Database? _database;

      DatabaseHelper._internal();

      Future<Database> get database async {
        if (_database != null) return _database!;
        _database = await _initDatabase();
        return _database!;
      }

      Future<Database> _initDatabase() async {
        String path = join(await getDatabasesPath(), 'load_balancer.db');
        return await openDatabase(
          path,
          version: 1,
          onCreate: _onCreate,
        );
      }

      Future<void> _onCreate(Database db, int version) async {
        await db.execute('''
          CREATE TABLE appliances(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            powerConsumption REAL,
            priority INTEGER,
            isOn INTEGER
          )
        ''');
      }

      Future<int> insertAppliance(Appliance appliance) async {
        Database db = await database;
        return await db.insert('appliances', appliance.toMap());
      }

      Future<List<Appliance>> getAppliances() async {
        Database db = await database;
        final List<Map<String, dynamic>> maps = await db.query('appliances');
        return List.generate(maps.length, (i) {
          return Appliance.fromMap(maps[i]);
        });
      }

      Future<int> updateAppliance(Appliance appliance) async {
        Database db = await database;
        return await db.update(
          'appliances',
          appliance.toMap(),
          where: 'id = ?',
          whereArgs: [appliance.id],
        );
      }

      Future<int> deleteAppliance(int id) async {
        Database db = await database;
        return await db.delete(
          'appliances',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      Future<void> close() async {
        Database db = await database;
        await db.close();
      }
    }
    
    class Appliance {
      int? id;
      String name;
      double powerConsumption;
      int priority;
      bool isOn;

      Appliance({
        this.id,
        required this.name,
        required this.powerConsumption,
        required this.priority,
        this.isOn = false,
      });

      Map<String, dynamic> toMap() {
        return {
          'id': id,
          'name': name,
          'powerConsumption': powerConsumption,
          'priority': priority,
          'isOn': isOn ? 1 : 0,
        };
      }

      factory Appliance.fromMap(Map<String, dynamic> map) {
        return Appliance(
          id: map['id'],
          name: map['name'],
          powerConsumption: map['powerConsumption'],
          priority: map['priority'],
          isOn: map['isOn'] == 1,
        );
      }
    }