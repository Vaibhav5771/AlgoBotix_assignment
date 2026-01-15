import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/stock_history.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'inventory.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE products (
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          stock INTEGER,
          imagePath TEXT,
          addedBy TEXT,
          createdAt TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE stock_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId TEXT,
          change INTEGER,
          timestamp TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE stock_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId TEXT,
            change INTEGER,
            timestamp TEXT
          )
        ''');
        }
      },
    );
  }

  static Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<bool> productExists(String id) async {
    final db = await database;
    final result =
    await db.query('products', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  static Future<void> updateProductStock(String id, int newStock) async {
    final db = await database;
    await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<Product?> getProductById(String id) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }


  static Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  static Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<void> insertStockHistory(StockHistory history) async {
    final db = await database;
    await db.insert('stock_history', history.toMap());
  }

  static Future<List<Map<String, dynamic>>> getStockHistory(String productId) async {
    final db = await database;
    return db.query(
      'stock_history',
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'timestamp DESC',
    );
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return db.query('products', orderBy: 'createdAt DESC');
  }
}
