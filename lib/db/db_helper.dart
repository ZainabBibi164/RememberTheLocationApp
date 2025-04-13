import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/location.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('remember_location.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      address TEXT NOT NULL,
      password TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE location_notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      imagePath TEXT,
      FOREIGN KEY (userId) REFERENCES users (id)
    )
    ''');
  }

  Future<bool> userExists(String name) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'name = ?',
      whereArgs: [name],
    );
    return result.isNotEmpty;
  }

  Future<int> createUser(User user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<User?> getUser(String name, String password) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );
    if (maps.isNotEmpty) {
      return User(
        id: maps.first['id'] as int,
        name: maps.first['name'] as String,
        address: maps.first['address'] as String,
        password: maps.first['password'] as String,
      );
    }
    return null;
  }

  Future<int> createNote(LocationNote note) async {
    final db = await database;
    try {
      return await db.insert('location_notes', note.toMap());
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  Future<List<LocationNote>> getNotes(int userId) async {
    final db = await database;
    final maps = await db.query(
      'location_notes',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps
        .map((map) => LocationNote(
      id: map['id'] as int,
      userId: map['userId'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      imagePath: map['imagePath'] as String?,
    ))
        .toList();
  }

  Future<int> updateNote(LocationNote note) async {
    final db = await database;
    try {
      return await db.update(
        'location_notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'location_notes',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}