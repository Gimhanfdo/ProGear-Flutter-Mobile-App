import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseHelper {
  // Singleton instance to ensure only one database helper exists
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  // Database configuration
  static const _dbName = 'progear_local.db';
  static const _dbVersion = 1;

  static const _wishlistTable = 'wishlist'; // Table name for wishlist
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DatabaseHelper._internal();

  // Get database instance 
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath(); // Get default database path
    final path = join(dbPath, _dbName); // Full path with file name

    // Opens a DB connection
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  // Create wishlist table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_wishlistTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT,
        product_price REAL,
        product_image TEXT
      )
    ''');
  }

  // Function to insert into wishlist
  Future<void> addToWishlist(Map<String, dynamic> product) async {
    final db = await database;
    final userId = await _secureStorage.read(key: 'user_id');

    await db.insert(
      _wishlistTable,
      {
        'user_id': userId ?? 'guest',
        'product_id': product['id'],
        'product_name': product['name'],
        'product_price': product['price'],
        'product_image': product['image'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if already exists
    );
  }

  // Function to retrieve wishlist for the current user
  Future<List<Map<String, dynamic>>> getWishlist() async {
    final db = await database;
    final userId = await _secureStorage.read(key: 'user_id'); // Get current user ID from secure storage
    return await db.query(
      _wishlistTable,
      where: 'user_id = ?',
      whereArgs: [userId ?? 'guest'],
    );
  }

  // Function to remove a product from wishlist
  Future<void> removeFromWishlist(int productId) async {
    final db = await database;
    final userId = await _secureStorage.read(key: 'user_id'); // Get current user ID from secure storage
    await db.delete(
      _wishlistTable,
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId ?? 'guest', productId],
    );
  }

  // Function to clear wishlist for a specific user
  Future<void> clearWishlist() async {
    final db = await database;
    final userId = await _secureStorage.read(key: 'user_id'); // Get current user ID from secure storage
    await db.delete(
      _wishlistTable,
      where: 'user_id = ?',
      whereArgs: [userId ?? 'guest'],
    );
  }
}
