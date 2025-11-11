// db/database_helper.dart

import 'package:projetoflutter/models/animal_model.dart';
import 'package:projetoflutter/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('animals.db');
    return _database!;
  }

  Future<Database> _initDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE animals (
        id $idType,
        nome $textType,
        especie $textType,
        idade $intType
      )
    ''');

    await _createUsersTable(db);
  }

  // --- FUNÇÕES CRUD ---

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUsersTable(db);
    }
  }

  Future _createUsersTable(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        email $textType UNIQUE,
        senha $textType
      )
    ''');
  }

  // Criar um novo usuário (Cadastro)
  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return User(id: id, email: user.email, password: user.password);
  }

  // Checar login
  Future<User?> login(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'email', 'senha'],
      where: 'email = ? AND senha = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // CREATE (Inserir)
  Future<Animal> create(Animal animal) async {
    final db = await instance.database;
    final id = await db.insert('animals', animal.toMap());
    final newAnimal = Animal(
        id: id,
        name: animal.name,
        species: animal.species,
        age: animal.age);
    return newAnimal;
  }

  // READ (Ler um animal)
  Future<Animal> readAnimal(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'animals',
      columns: ['id', 'nome', 'especie', 'idade'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Animal.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  // READ ALL (Ler todos os animais)
  Future<List<Animal>> readAllAnimals() async {
    final db = await instance.database;
    final result = await db.query('animals', orderBy: 'nome ASC');
    return result.map((json) => Animal.fromMap(json)).toList();
  }

  // UPDATE (Atualizar)
  Future<int> update(Animal animal) async {
    final db = await instance.database;
    return db.update(
      'animals',
      animal.toMap(),
      where: 'id = ?',
      whereArgs: [animal.id],
    );
  }

  // DELETE (Excluir)
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}