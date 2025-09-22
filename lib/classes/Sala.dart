import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart';

class Sala {
  int? id_sala;
  String codigo_barra;
  String num_sala;
  int isSynced; // 0 = não sincronizado, 1 = sincronizado
  DateTime lastUpdated;

  Sala({
    this.id_sala,
    required this.codigo_barra,
    required this.num_sala,
    this.isSynced = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'inventario.db');
    return await openDatabase(
      path,
      version: 2, // 🔹 aumentei versão para recriar tabela com novos campos
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sala (
            id_sala INTEGER PRIMARY KEY AUTOINCREMENT,
            codigo_barra TEXT UNIQUE NOT NULL,
            num_sala TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0,
            lastUpdated TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Abre e garante que a tabela exista
  static Future<void> openDb() async {
    try {
      Database db = await database;
      await db.transaction((txn) async {
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS sala (
            id_sala INTEGER PRIMARY KEY AUTOINCREMENT,
            codigo_barra TEXT UNIQUE NOT NULL,
            num_sala TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0,
            lastUpdated TEXT NOT NULL
          )
        ''');
      });
    } catch (e) {
      print("Erro ao criar tabela sala: $e");
    }
  }

  /// Deletar sala
  static Future<int> delete(int id) async {
    var db = await database;
    return await db.delete('sala', where: 'id_sala = ?', whereArgs: [id]);
  }


  Map<String, Object?> toMap() {
    return {
      'id_sala': id_sala,
      'codigo_barra': codigo_barra,
      'num_sala': num_sala,
      'isSynced': isSynced,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static Future<int?> insert(Sala sala) async {
    openDb();
    var db = await database;
    try {
      return await db.insert('sala', sala.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Erro ao inserir sala: $e');
      return null;
    }
  }

  static Future<List<Sala>> getAllSalas() async {
    openDb();
    var db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sala');
    return List.generate(maps.length, (i) => Sala.fromMap(maps[i]));
  }

  static Future<List<Sala>> getUnsyncedSalas() async {
    var db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('sala', where: 'isSynced = ?', whereArgs: [0]);
    return List.generate(maps.length, (i) => Sala.fromMap(maps[i]));
  }

  factory Sala.fromMap(Map<String, dynamic> map) {
    return Sala(
      id_sala: map['id_sala'],
      codigo_barra: map['codigo_barra'],
      num_sala: map['num_sala'],
      isSynced: map['isSynced'] ?? 0,
      lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? '') ??
          DateTime.now(),
    );
  }
}
