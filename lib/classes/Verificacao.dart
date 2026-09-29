import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Artigo.dart';

class Verificacao {
  int? id_verificacao;
  String id_inventario;
  String num_artigo;
  String nome_artigo;
  DateTime data_registo;
  int isSynced;
  Verificacao({
    // required this.id_verificacao,
    required this.id_inventario,
    required this.num_artigo,
    required this.nome_artigo,
    required this.data_registo,
    required this.isSynced,
  });

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    String path = join(
      await getDatabasesPath(),
      'inventario.db',
    );
    print("[Verificacao]Caminho do banco de dados: $path");
    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS verificacao (
          id_verificacao INTEGER PRIMARY KEY AUTOINCREMENT,
          id_inventario TEXT NOT NULL,
          num_artigo TEXT NOT NULL,
          nome_artigo TEXT,
          data_registo TEXT NOT NULL,
          isSynced INTEGER DEFAULT 0
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS verificacao (
            id_verificacao INTEGER PRIMARY KEY AUTOINCREMENT,
            id_inventario TEXT NOT NULL,
            num_artigo TEXT NOT NULL,
            nome_artigo TEXT,
            data_registo TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0
          )
        ''');
        }
      },
    );
  }

  factory Verificacao.fromServerMap(Map<String, dynamic> map) {
    return Verificacao(
      //  id_verificacao: 0,
      id_inventario: map["id_inventario"],
      num_artigo: map["num_artigo"],
      nome_artigo: map["nome_artigo"],
      data_registo: DateTime.now(),
      isSynced: (map["isSynced"] == true) ? 1 : 0,
    );
  }
  static Future<void> openDb() async {
    print("[Verificacao] Abrindo banco de dados...");
    try {
      Database db = await database;
      await db.transaction((txn) async {
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS verificacao (
            id_verificacao INTEGER PRIMARY KEY AUTOINCREMENT,
            id_inventario TEXT NOT NULL,
            num_artigo TEXT NOT NULL,
            nome_artigo TEXT,
            data_registo TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0
        )
      ''');
      });
    } catch (e) {
      print("Erro ao criar tabela verificação: $e");
    }
  }

  Map<String, Object?> toMap() {
    return {
      // 'id_verificacao': id_verificacao,
      'id_inventario': id_inventario,
      'num_artigo': num_artigo,
      'nome_artigo': nome_artigo,
      'data_registo': data_registo.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  static Future<List<Verificacao>> getVerificacoesByInventario(
      int idInventario) async {
    openDb();
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT * FROM verificacao
    WHERE id_inventario = ?
  ''', [idInventario]);

    return List.generate(result.length, (i) => Verificacao.fromMap(result[i]));
  }

  static Future<List<Verificacao>> getAll() async {
    //  openDb();
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('verificacao');
    return List.generate(result.length, (i) => Verificacao.fromMap(result[i]));
  }

  factory Verificacao.fromMap(Map<String, dynamic> map) {
    return Verificacao(
      //id_verificacao: map['id_verificacao'] ?? 0,
      id_inventario: map['id_inventario'] ?? '',
      num_artigo: map['num_artigo']?.toString() ?? "",
      data_registo: map['data_registo'] != null
          ? DateTime.tryParse(map['data_registo']) ?? DateTime.now()
          : DateTime.now(),
      isSynced: map['isSynced'] ?? 0,
      nome_artigo: map['nome_artigo'] ?? '',
    );
  }

  static Future<int?> insert(Verificacao verificacao) async {
    var db = await database;
    try {
      return await db.insert('verificacao', verificacao.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Erro ao inserir verificação: $e');
      return null;
    }
  }

  static Future<void> insertOrUpdate(Verificacao verificacao) async {
    openDb();
    var db = await database;
    try {
      await db.insert(
        'verificacao',
        verificacao.toMap(),
        conflictAlgorithm:
            ConflictAlgorithm.replace, // substitui se já existir mesma PK
      );
    } catch (e) {
      print('Erro ao inserir ou atualizar verificação: $e');
    }
  }

  static Future<List<Verificacao>> getAllVerificacoes() async {
    var db = await database;
    final List<Map<String, dynamic>> maps = await db.query('verificacao');
    return List.generate(maps.length, (i) => Verificacao.fromMap(maps[i]));
  }

  static Future<List<Verificacao>> getUnsyncedVerificacoes() async {
    var db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('verificacao', where: 'isSynced = ?', whereArgs: [0]);
    return List.generate(maps.length, (i) => Verificacao.fromMap(maps[i]));
  }

  static Future<void> updateSyncStatus(
      String idInventario, String numArtigo, int isSynced) async {
    var db = await database;
    try {
      await db.update(
        'verificacao',
        {'isSynced': isSynced},
        where: 'id_inventario = ? AND num_artigo = ?',
        whereArgs: [idInventario, numArtigo],
      );
    } catch (e) {
      print('Erro ao atualizar status de sincronização: $e');
    }
  }
}
