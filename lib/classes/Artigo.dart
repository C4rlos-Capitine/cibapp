import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart';

class Artigo {
  int? id_artigo;
  int id_sala;//1
  String codigo_barra;//2
  String num_artigo;//3
  String nome_artigo;//4
  String unique_id_artigo;//5
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
    required this.unique_id_artigo,
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
            codigo_barra TEXT UNIQUE NOT NULL,
            num_artigo TEXT NOT NULL,
            nome_artigo TEXT NOT NULL,
            unique_id_artigo TEXT NOT NULL,
            data_registo TEXT NOT NULL,
            data_update TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0,
            lastUpdated TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<Artigo?> getByCodigoBarra(String codigoBarra) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'artigo',
      where: 'codigo_barra = ?',
      whereArgs: [codigoBarra],
    );

    if (maps.isNotEmpty) {
      return Artigo.fromMap(maps.first);
    }

    return null;
  }

  static Future<List<Artigo>> getArtigosByInventario(int idInventario) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT a.* FROM artigo a
    INNER JOIN inventario_artigo ia ON a.id_artigo = ia.id_artigo
    WHERE ia.id_inventario = ?
  ''', [idInventario]);

    return List.generate(result.length, (i) => Artigo.fromMap(result[i]));
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
            codigo_barra TEXT UNIQUE NOT NULL,
            num_artigo TEXT NOT NULL,
            nome_artigo TEXT NOT NULL,
            unique_id_artigo TEXT NOT NULL,
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

  static Future<List<Artigo>> getBySala(int idSala) async {
    openDb();
    var db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'artigo',
      where: 'id_sala = ?',
      whereArgs: [idSala],
    );

    return List.generate(maps.length, (i) => Artigo.fromMap(maps[i]));
  }



  Map<String, Object?> toMap() {
    return {
      'id_artigo': id_artigo,
      'codigo_barra': codigo_barra,
      'num_artigo': num_artigo,
      'nome_artigo': nome_artigo,
      'unique_id_artigo': unique_id_artigo,
      'data_registo': data_registo.toIso8601String(),
      'data_update': data_update.toIso8601String(),
      'isSynced': isSynced, // bool, não int
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }


  Map<String, Object?> toMapToServer() {
    return {
      'id_artigo': unique_id_artigo,
      'codigo_barra': codigo_barra,
      'num_artigo': num_artigo,
      'nome_artigo': nome_artigo,
      'data_registo': data_registo.toIso8601String(),
      'data_update': data_update.toIso8601String(),
      'isSynced': isSynced, // bool, não int
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Artigo.fromServerMap(Map<String, dynamic> map) {
    return Artigo(
      unique_id_artigo: map["id_artigo"],
      codigo_barra: map["codigo_barra"],
      num_artigo: map["num_artigo"],
      nome_artigo: map["nome_artigo"],
      isSynced: (map["isSynced"] == true) ? 1 : 0,
      lastUpdated: DateTime.tryParse(map["lastUpdated"] ?? "") ?? DateTime.now(), id_sala: 0, data_registo: DateTime.now(), data_update: DateTime.now(),
    );
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

  static Future<void> insertOrUpdate(Artigo artigo) async {
    openDb();
    var db = await database;

    await db.insert(
      'artigo',
      artigo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // substitui se já existir mesma PK
    );
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
      id_artigo: map['id_artigo'] ?? 0,
      id_sala: map['id_sala'] ?? 0,
      codigo_barra: map['codigo_barra']?.toString() ?? "",
      num_artigo: map['num_artigo']?.toString() ?? "",
      nome_artigo: map['nome_artigo']?.toString() ?? "",
      data_registo: DateTime.parse(map['data_registo']),
      data_update: DateTime.parse(map['data_update']),
      isSynced:map['isSynced'] ?? 0,
      lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(), unique_id_artigo: map['unique_id_artigo'],
    );
  }

  factory Artigo.fromMapAPI(Map<String, dynamic> map) {
    return Artigo(
      id_sala: 0,
      codigo_barra: map['codigo_barra']?.toString() ?? "",
      num_artigo: map['codigo_barra']?.toString() ?? "",
      nome_artigo: map['nome_artigo']?.toString() ?? "",
      data_registo: map['data_registo'] != null? DateTime.tryParse(map['data_registo']) ?? DateTime.now(): DateTime.now(),
      data_update: map['data_update'] != null ? DateTime.tryParse(map['data_update']) ?? DateTime.now() : DateTime.now(),
      isSynced: map['isSynced'] ?? 0,
      lastUpdated: map['lastUpdated'] != null? DateTime.tryParse(map['lastUpdated']) ?? DateTime.now() : DateTime.now(),
      unique_id_artigo: map['id_artigo'],
    );
  }


}

class Artigo2{
  int? id_artigo;
  int id_sala;
  String codigo_barra;
  String num_artigo;
  String nome_artigo;
  DateTime data_registo;
  DateTime data_update;
  int isSynced; // 0 = não sincronizado, 1 = sincronizado
  DateTime lastUpdated;

  Artigo2({
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


  factory Artigo2.fromMap(Map<String, dynamic> map) {
    return Artigo2(
      id_artigo: map['id_Artigo'] ?? 0,
      id_sala: map['id_Sala'] ?? 0,
      codigo_barra: map['codigo_Barra']?.toString() ?? "",
      num_artigo: map['num_Artigo']?.toString() ?? "",
      nome_artigo: map['nome_Artigo']?.toString() ?? "",
      data_registo: map['data_Registo'] != null
          ? DateTime.tryParse(map['data_Registo']) ?? DateTime.now()
          : DateTime.now(),
      data_update: map['data_Update'] != null
          ? DateTime.tryParse(map['data_Update']) ?? DateTime.now()
          : DateTime.now(),
      isSynced: map['isSynced'] ?? 0,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.tryParse(map['lastUpdated']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

}


