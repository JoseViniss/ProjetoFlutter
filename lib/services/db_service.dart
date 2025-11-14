import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dog.dart';
import '../models/user.dart';

class DBService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'adopet_database_v3.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        telefone TEXT, 
        cidade TEXT,
        sobre TEXT 
      )
    ''');

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
        isCastrated INTEGER NOT NULL DEFAULT 0,
        latitude REAL,
        longitude REAL,
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
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

  Future<User> createUser(User user) async {
    final db = await database;
    final id = await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    // Retorna o usuário com o novo ID
    return user.copyWith(id: id);
  }

  Future<User?> login(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
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

  Future<int> countDogsForUser(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM dogs WHERE userId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, int>> getVaccinationStatsForUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT vaccinationStatus, COUNT(*) as count FROM dogs WHERE userId = ? GROUP BY vaccinationStatus',
      [userId],
    );

    final Map<String, int> stats = {};
    for (var row in result) {
      stats[row['vaccinationStatus']] = row['count'];
    }
    return stats;
  }

  Future<List<Dog>> getDogsForUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dogs',
      where: 'userId = ?', // Filtra pelo ID do usuário
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Dog.fromMap(maps[i]));
  }

}