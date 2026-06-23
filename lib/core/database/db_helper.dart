import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'asset_management.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ASSETS TABLE
    await db.execute('''
      CREATE TABLE assets (
        assetId TEXT PRIMARY KEY,
        assetName TEXT NOT NULL,
        category TEXT NOT NULL,
        brand TEXT,
        modelNumber TEXT,
        serialNumber TEXT,
        purchaseDate TEXT,
        warrantyExpiryDate TEXT,
        status TEXT NOT NULL DEFAULT 'Available'
      )
    ''');

    // EMPLOYEES TABLE
    await db.execute('''
      CREATE TABLE employees (
        employeeId TEXT PRIMARY KEY,
        employeeName TEXT NOT NULL,
        department TEXT NOT NULL
      )
    ''');

    // ASSIGNMENTS TABLE (also serves as history log)
    await db.execute('''
      CREATE TABLE assignments (
        assignmentId TEXT PRIMARY KEY,
        assetId TEXT NOT NULL,
        employeeId TEXT NOT NULL,
        employeeName TEXT NOT NULL,
        department TEXT NOT NULL,
        assignedDate TEXT NOT NULL,
        returnedDate TEXT,
        remarks TEXT,
        status TEXT NOT NULL DEFAULT 'Active',
        FOREIGN KEY (assetId) REFERENCES assets (assetId)
      )
    ''');

    // ASSET HISTORY TABLE (logs every action: created, updated, assigned, returned)
    await db.execute('''
      CREATE TABLE asset_history (
        historyId TEXT PRIMARY KEY,
        assetId TEXT NOT NULL,
        action TEXT NOT NULL,
        details TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (assetId) REFERENCES assets (assetId)
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
