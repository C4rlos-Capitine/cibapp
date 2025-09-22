import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Method to initialize the database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      // Create the database and return it
      _database = await _initDb();
      return _database!;
    }
  }

  // Open database (or create it if it doesn't exist)
  Future<Database> _initDb() async {
    // Get the path to the database file
    String path = join(await getDatabasesPath(), 'producto.db');

    // Open the database and return the instance
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Initial setup when the database is created
        print("Creating tables in database");
        await db.execute("CREATE TABLE IF NOT EXISTS producto(id INTEGER PRIMARY KEY AUTOINCREMENT, nome_prod TEXT, preco REAL)");
        await db.execute("CREATE TABLE IF NOT EXISTS codigos_prod(id INTEGER PRIMARY KEY, numero INTEGER)");
      },
    );
  }

  // Method to perform operations inside a transaction
  Future<void> openDb() async {
    print("OPENDB METHOD INVOKED");
    try{
      Database db = await database;

      // Start the transaction
      await db.transaction((txn) async {
        // Create table Test1 inside the transaction
        await txn.execute("CREATE TABLE IF NOT EXISTS producto(id INTEGER PRIMARY KEY AUTOINCREMENT, nome_prod TEXT, preco REAL)");

        // Create table Test2 inside the transaction
        await txn.execute("CREATE TABLE IF NOT EXISTS codigos_prod(id INTEGER PRIMARY KEY, numero INTEGER)");
      });

      print("DATABASE TABLES CREATED SUCCESSFULLY");
    }catch(e){
      print("EXCEPTION CREATION: $e");
    }
    // Get the database instance

  }
}