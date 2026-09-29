import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Artigo.dart';

class InventarioArtigo {
  int? id_inventario_artigo;
  int id_inventario;
  int id_artigo;
  String unique_id_sala;
  String unioque_id_inventario_artigo;
  String unique_id_inventario;
  String unique_id_artigo;
  String nome_artigo;
  String num_artigo;
  String nome_sala_actual;
  DateTime data_associacao;
  int isSynced;
  DateTime lastUpdated;

  InventarioArtigo({
    this.id_inventario_artigo,
    required this.id_inventario,
    required this.id_artigo,
    required this.unique_id_sala,
    required this.unioque_id_inventario_artigo,
    required this.unique_id_inventario,
    required this.unique_id_artigo,
    required this.nome_artigo,
    required this.num_artigo,
    required this.nome_sala_actual,
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
            unique_id_sala TEXT NOT NULL,
            unique_id_inventario TEXT NOT NULL,
            unioque_id_inventario_artigo TEXT NOT NULL,
            unique_id_artigo TEXT NOT NULL,
            nome_artigo TEXT NOT NULL,
            num_artigo TEXT NOT NULL,
            nome_sala_actual TEXT,
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
            unique_id_sala TEXT NOT NULL,
            unique_id_inventario TEXT NOT NULL,
            unioque_id_inventario_artigo TEXT NOT NULL,
            unique_id_artigo TEXT NOT NULL,
            nome_artigo TEXT NOT NULL,
            num_artigo TEXT NOT NULL,
            nome_sala_actual TEXT,
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
      'unique_id_sala': unique_id_sala,
      'unique_id_inventario': unique_id_inventario,
      'unioque_id_inventario_artigo': unioque_id_inventario_artigo,
      'unique_id_artigo':unique_id_artigo,
      'nome_artigo': nome_artigo,
      'num_artigo': num_artigo,
      'nome_sala_actual': nome_sala_actual,
      'isSynced': isSynced,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static Future<List<InventarioArtigo>> getAll() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.query('inventario_artigo');
      print("egistros encontrados em inventario_artigo: ${jsonEncode(maps)}");
      return maps.map((map) => InventarioArtigo.fromMap(map)).toList();
    } catch (e) {
      print("Erro ao obter todos os InventarioArtigo: $e");
      return [];
    }
  }

  Map<String, Object?> toServerMap() {
    return {
      'id_inventario_artigo': id_inventario_artigo,
      'id_inventario': unique_id_inventario,
      'id_artigo': unique_id_artigo,
      'unique_id_inventario': unique_id_inventario,
      'nome_artigo': nome_artigo,
      'num_artigo': num_artigo,
      'nome_sala_actual': nome_sala_actual,
      'isSynced': isSynced,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Map<String, Object?> toServerMap2() {
    return {
      'id_inventario_artigo': unique_id_artigo,
      'id_inventario': unique_id_inventario,
      'id_artigo': unique_id_artigo,
      'unique_id_inventario': unique_id_inventario,
      'num_artigo': num_artigo,
      'nome_artigo': nome_artigo,
      'nome_sala_actual': nome_sala_actual,
      'isSynced':isSynced == 1 || isSynced == true,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static Future<void> insertOrUpdate(InventarioArtigo item) async {
    final db = await database;

    // Verifica se já existe pelo GUID
    final existing = await db.query(
      'inventario_artigo',
      where: 'id_inventario_artigo = ?',
      whereArgs: [item.id_inventario_artigo],
    );

    if (existing.isNotEmpty) {
      // Atualiza
      await db.update(
        'inventario_artigo',
        item.toMap(),
        where: 'id_inventario_artigo = ?',
        whereArgs: [item.id_inventario_artigo],
      );
    } else {
      // Insere
      await db.insert(
        'inventario_artigo',
        item.toMap(),
      );
    }
  }

  /// 🔹 Retorna todos os itens de inventário não sincronizados
  static Future<List<InventarioArtigo2>> getUnsyncedInventarioArtigos() async {
    final db = await database;
    final maps = await db
        .query('inventario_artigo', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((map) => InventarioArtigo2.fromMap(map)).toList();
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
      lastUpdated:
          DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
      unique_id_sala: map['unique_id_sala'],
      unioque_id_inventario_artigo: map['unioque_id_inventario_artigo'],
      unique_id_inventario: map['unique_id_inventario'],
      unique_id_artigo: map['unique_id_artigo'], nome_artigo: map['nome_artigo'], num_artigo: map['num_artigo'], nome_sala_actual: map['nome_sala_actual'],
    );
  }

  static Future<int> insert(InventarioArtigo ia) async {
    try {
      openDb();
      final db = await database;

      // 🔹 Mostra o conteúdo do objeto antes de inserir
      print("🟦 Inserindo InventarioArtigo:");
      print("  id_inventario_artigo: ${ia.id_inventario_artigo}");
      print("  id_inventario: ${ia.id_inventario}");
      print("  id_artigo: ${ia.id_artigo}");
      print("  unique_id_sala: ${ia.unique_id_sala}");
      print("  unioque_id_inventario_artigo: ${ia.unioque_id_inventario_artigo}");
      print("  unique_id_inventario: ${ia.unique_id_inventario}");
      print("  unique_id_artigo: ${ia.unique_id_artigo}");
      print("  data_associacao: ${ia.data_associacao}");
      print("  isSynced: ${ia.isSynced}");
      print("  num_artigo: ${ia.num_artigo}");
      print("  lastUpdated: ${ia.lastUpdated}");
      print("  nome_sala_actual ${ia.nome_sala_actual}");

      // 🔹 Inserção com tratamento de conflito
      final id = await db.insert(
        'inventario_artigo',
        ia.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print("✅ InventarioArtigo inserido com sucesso. ID: $id");
      return id;
    } catch (e, stack) {
      print("❌ Erro ao inserir InventarioArtigo: $e");
      print("Stack trace: $stack");
      return -1;
    }
  }


  static Future<List<InventarioArtigo>> getByInventario(
      int idInventario) async {
    final db = await database;
    final maps = await db.query(
      'inventario_artigo',
      where: 'id_inventario = ?',
      whereArgs: [idInventario],
    );
    return maps.map((e) => InventarioArtigo.fromMap(e)).toList();
  }
}

class InventarioArtigo2 {
  String id_inventario_artigo;
  String id_inventario;
  String id_artigo;
  String unique_id_sala;
  int isSynced;

  InventarioArtigo2(
      {required this.id_inventario_artigo,
      required this.id_inventario,
      required this.id_artigo,
      required this.unique_id_sala,
      required this.isSynced});

  factory InventarioArtigo2.fromMap(Map<String, dynamic> map) {
    return InventarioArtigo2(
        id_inventario_artigo: map['unioque_id_inventario_artigo'] ?? "",
        id_inventario: map['unique_id_inventario'] ?? "",
        id_artigo: map['unique_id_artigo'] ?? "",
        unique_id_sala: map['unique_id_sala'] ?? "",
        isSynced: map['isSynced']);
  }


}
