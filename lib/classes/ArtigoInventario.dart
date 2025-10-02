import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Artigo.dart';

class InventarioArtigo {
  int? id_inventario_artigo;
  int id_inventario;
  int id_artigo;
  DateTime data_associacao;
  int isSynced;
  DateTime lastUpdated;

  InventarioArtigo({
    this.id_inventario_artigo,
    required this.id_inventario,
    required this.id_artigo,
    DateTime? data_associacao,
    this.isSynced = 0,
    DateTime? lastUpdated,
  })  : data_associacao = data_associacao ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE inventario_artigo (
            id_inventario_artigo INTEGER PRIMARY KEY AUTOINCREMENT,
            id_inventario INTEGER NOT NULL,
            id_artigo INTEGER NOT NULL,
            data_associacao TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0,
            lastUpdated TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> openDb() async {
    try {
      Database db = await database;
      await db.transaction((txn) async {
        await txn.execute('''
         CREATE TABLE inventario_artigo (
            id_inventario_artigo INTEGER PRIMARY KEY AUTOINCREMENT,
            id_inventario INTEGER NOT NULL,
            id_artigo INTEGER NOT NULL,
            data_associacao TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0,
            lastUpdated TEXT NOT NULL
          )
        ''');
      });
    } catch (e) {
      print("Erro ao criar tabela sala: $e");
    }
  }

  Map<String, Object?> toMap() {
    return {
      'id_inventario_artigo': id_inventario_artigo,
      'id_inventario': id_inventario,
      'id_artigo': id_artigo,
      'data_associacao': data_associacao.toIso8601String(),
      'isSynced': isSynced,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static Future<void> insertOrUpdate(InventarioArtigo item) async {
    final db = await database;

    // Verifica se já existe pelo GUID
    final existing = await db.query(
      'InventarioArtigo',
      where: 'id_inventario_artigo = ?',
      whereArgs: [item.id_inventario_artigo],
    );

    if (existing.isNotEmpty) {
      // Atualiza
      await db.update(
        'InventarioArtigo',
        item.toMap(),
        where: 'id_inventario_artigo = ?',
        whereArgs: [item.id_inventario_artigo],
      );
    } else {
      // Insere
      await db.insert(
        'InventarioArtigo',
        item.toMap(),
      );
    }
  }

  /// 🔹 Retorna todos os itens de inventário não sincronizados
  static Future<List<InventarioArtigo>> getUnsyncedInventarioArtigos() async {
    final db = await database;
    final maps = await db.query('InventarioArtigo', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((map) => InventarioArtigo.fromMap(map)).toList();
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


  factory InventarioArtigo.fromMap(Map<String, dynamic> map) {
    return InventarioArtigo(
      id_inventario_artigo: map['id_inventario_artigo'],
      id_inventario: map['id_inventario'],
      id_artigo: map['id_artigo'],
      data_associacao: DateTime.parse(map['data_associacao']),
      isSynced: map['isSynced'] ?? 0,
      lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  static Future<int> insert(InventarioArtigo ia) async {
    final db = await database;
    return await db.insert('inventario_artigo', ia.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<InventarioArtigo>> getByInventario(int idInventario) async {
    final db = await database;
    final maps = await db.query(
      'inventario_artigo',
      where: 'id_inventario = ?',
      whereArgs: [idInventario],
    );
    return maps.map((e) => InventarioArtigo.fromMap(e)).toList();
  }
}
