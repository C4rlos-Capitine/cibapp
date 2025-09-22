import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart';

class Artigo {
  int? id_artigo;
  int id_sala;
  String codigo_barra;
  String num_artigo;
  String nome_artigo;
  DateTime data_registo;
  DateTime data_update;
  int isSynced; // 0 = não sincronizado, 1 = sincronizado
  DateTime lastUpdated;

  Artigo({
    this.id_artigo,
    required this.id_sala,
    required this.codigo_barra,
    required this.num_artigo,
    required this.nome_artigo,
    required this.data_registo,
    required this.data_update,
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
      version: 2, // 🔹 aumentei versão
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE artigo (
            id_artigo INTEGER PRIMARY KEY AUTOINCREMENT,
            id_sala INTEGER NOT NULL,
            codigo_barra TEXT UNIQUE NOT NULL,
            num_artigo TEXT NOT NULL,
            nome_artigo TEXT NOT NULL,
            data_registo TEXT NOT NULL,
            data_update TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0,
            lastUpdated TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Deletar artigo
  static Future<int> delete(int id) async {
    var db = await database;
    return await db.delete('artigo', where: 'id_artigo = ?', whereArgs: [id]);
  }
  /// Garante que a tabela exista
  static Future<void> openDb() async {
    try {
      Database db = await database;
      await db.transaction((txn) async {
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS artigo (
            id_artigo INTEGER PRIMARY KEY AUTOINCREMENT,
            id_sala INTEGER NOT NULL,
            codigo_barra TEXT UNIQUE NOT NULL,
            num_artigo TEXT NOT NULL,
            nome_artigo TEXT NOT NULL,
            data_registo TEXT NOT NULL,
            data_update TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0,
            lastUpdated TEXT NOT NULL
          )
        ''');
      });
    } catch (e) {
      print("Erro ao criar tabela artigo: $e");
    }
  }

  Map<String, Object?> toMap() {
    return {
      'id_artigo': id_artigo,
      'id_sala': id_sala,
      'codigo_barra': codigo_barra,
      'num_artigo': num_artigo,
      'nome_artigo': nome_artigo,
      'data_registo': data_registo.toIso8601String(),
      'data_update': data_update.toIso8601String(),
      'isSynced': isSynced,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static Future<int?> insert(Artigo artigo) async {
    openDb();
    var db = await database;
    try {
      return await db.insert('artigo', artigo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Erro ao inserir artigo: $e');
      return null;
    }
  }

  static Future<List<Artigo>> getAllArtigos() async {
    openDb();
    var db = await database;
    final List<Map<String, dynamic>> maps = await db.query('artigo');
    return List.generate(maps.length, (i) => Artigo.fromMap(maps[i]));
  }

  static Future<List<Artigo>> getUnsyncedArtigos() async {
    var db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('artigo', where: 'isSynced = ?', whereArgs: [0]);
    return List.generate(maps.length, (i) => Artigo.fromMap(maps[i]));
  }

  factory Artigo.fromMap(Map<String, dynamic> map) {
    return Artigo(
      id_artigo: map['id_artigo'],
      id_sala: map['id_sala'],
      codigo_barra: map['codigo_barra'],
      num_artigo: map['num_artigo'],
      nome_artigo: map['nome_artigo'],
      data_registo: DateTime.parse(map['data_registo']),
      data_update: DateTime.parse(map['data_update']),
      isSynced: map['isSynced'] ?? 0,
      lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? '') ??
          DateTime.now(),
    );
  }
}


