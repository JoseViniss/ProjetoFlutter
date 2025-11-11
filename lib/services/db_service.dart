import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dog.dart';

class DBService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'adopet_database_v2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        photoUrl TEXT NOT NULL,
        breed TEXT,
        sex TEXT,
        age INTEGER,
        size TEXT,
        color TEXT,
        description TEXT,
        city TEXT,
        healthStatus TEXT,
        vaccinationStatus TEXT,
        isCastrated INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE favorites (
        dogId INTEGER PRIMARY KEY
      )
    ''');

   
    await db.execute('''
      CREATE TABLE adoptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dogName TEXT,
        adopterName TEXT,
        date TEXT
      )
    ''');
  }

  Future<void> insertDog(Dog dog) async {
    final db = await database;
    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

 
  Future<void> updateDog(Dog dog) async {
    final db = await database;
    await db.update(
      'dogs',
      dog.toMap(),
      where: 'id = ?',
      whereArgs: [dog.id],
    );
  }

  
  Future<void> deleteDog(int id) async {
    final db = await database;
    await db.delete(
      'dogs',
      where: 'id = ?',
      whereArgs: [id],
    );
   
    await db.delete('favorites', where: 'dogId = ?', whereArgs: [id]);
  }

  Future<List<Dog>> getDogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dogs');
    return List.generate(maps.length, (i) => Dog.fromMap(maps[i]));
  }

  Future<void> addFavorite(int dogId) async {
    final db = await database;
    await db.insert('favorites', {'dogId': dogId},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(int dogId) async {
    final db = await database;
    await db.delete('favorites', where: 'dogId = ?', whereArgs: [dogId]);
  }

  Future<List<int>> getFavoriteIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) => maps[i]['dogId']);
  }

  Future<void> markAdopted(int dogId, String adopterName) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query('dogs', where: 'id = ?', whereArgs: [dogId]);
    if (maps.isNotEmpty) {
      final dogName = maps.first['name'];
      
      
      await db.insert('adoptions', {
        'dogName': dogName,
        'adopterName': adopterName,
        'date': DateTime.now().toString(),
      });

     
      await deleteDog(dogId);
    }
  }

  Future<List<Map<String, dynamic>>> getAdoptionsReport() async {
    final db = await database;
    return await db.query('adoptions');
  }
}