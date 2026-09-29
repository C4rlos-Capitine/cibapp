import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Inventario {
  int? id_inventario;
  String id_inventario_unique;
  int id_sala;
  String nome_inventario;
  String codigo_sala;
  DateTime data_inicio;
  DateTime? data_fim;
  String unique_id_sala;
  int isSynced;
  DateTime lastUpdated;

  Inventario({
    this.id_inventario,
    required this.id_sala,
    required this.nome_inventario,
    required this.data_inicio,
    required this.unique_id_sala,
    required this.id_inventario_unique,
    required this.codigo_sala,
    this.data_fim,
    this.isSynced = 0,
    required this.lastUpdated,
  });

  factory Inventario.fromMap(Map<String, dynamic> map) {
    return Inventario(
      id_inventario: map['id_inventario'],
      id_sala: map['id_sala'],
      nome_inventario: map['nome_inventario'],
      data_inicio: DateTime.parse(map['data_inicio']),
      unique_id_sala: map['unique_id_sala'],
      data_fim:
          map['data_fim'] != null ? DateTime.parse(map['data_fim']) : null,
      isSynced: map['isSynced'] ?? 0,
      lastUpdated: DateTime.parse(map['lastUpdated']),
      id_inventario_unique: map['id_inventario_unique'],
      codigo_sala: map['codigo_sala'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_inventario': id_inventario,
      'id_sala': id_sala,
      'nome_inventario': nome_inventario,
      'data_inicio': data_inicio.toIso8601String(),
      'data_fim': data_fim?.toIso8601String(),
      'unique_id_sala': unique_id_sala,
      'codigo_sala': codigo_sala,
      'id_inventario_unique': id_inventario_unique,
      'isSynced': isSynced,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Map<String, dynamic> toServerMap() {
    return {
      'id_inventario': id_inventario_unique,
      'unique_id_sala': unique_id_sala,
      'nome_inventario': nome_inventario,
      'codigo_sala': codigo_sala,
      'data_inicio': data_inicio.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isSynced': isSynced == 1 || isSynced == true, // 🔥 garante booleano
    };
  }

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
          CREATE TABLE inventario (
            id_inventario INTEGER PRIMARY KEY AUTOINCREMENT,
            nome_inventario TEXT NOT NULL,
            data_inicio TEXT NOT NULL,
            data_fim TEXT,
            unique_id_sala TEXT NOT NULL,
            id_inventario_unique TEXT NOT NULL,
            codigo_sala TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0,
            lastUpdated TEXT NOT NULL,
            id_sala INTEGER
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
          CREATE TABLE inventario (
            id_inventario INTEGER PRIMARY KEY AUTOINCREMENT,
            nome_inventario TEXT NOT NULL,
            data_inicio TEXT NOT NULL,
            data_fim TEXT,
            unique_id_sala TEXT NOT NULL,
            id_inventario_unique TEXT NOT NULL,
            codigo_sala TEXT NOT NULL,
            isSynced INTEGER DEFAULT 0,
            lastUpdated TEXT NOT NULL,
            id_sala INTEGER
          )
        ''');
      });
    } catch (e) {
      print("Erro ao criar tabela sala: $e");
    }
  }

  // 🔹 Método para pegar inventários não sincronizados
  static Future<List<Inventario>> getUnsyncedInventarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('inventario', where: 'isSynced = ?', whereArgs: [0]);

    return List.generate(maps.length, (i) => Inventario.fromMap(maps[i]));
  }

  static Future<int> insert(Inventario inv) async {
    final db = await database;
    return await db.insert('inventario', inv.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Map<String, dynamic> toMapForSync() {
    return {
      'id_Inventario': id_inventario ?? "", // GUID ou vazio
      'id_Sala': id_sala ?? "", // GUID string
      'nome_Inventario': nome_inventario,
      'data_Inicio': data_inicio.toIso8601String(),
      'unique_id_sala': unique_id_sala,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  static Future<void> insertOrUpdate(Inventario inv) async {
    final db = await database;

    // Verifica se já existe pelo GUID
    final existing = await db.query(
      'Inventario',
      where: 'id_inventario = ?',
      whereArgs: [inv.id_inventario],
    );

    if (existing.isNotEmpty) {
      // Atualiza
      await db.update(
        'Inventario',
        inv.toMap(),
        where: 'id_inventario = ?',
        whereArgs: [inv.id_inventario],
      );
    } else {
      // Insere
      await db.insert(
        'Inventario',
        inv.toMap(),
      );
    }
  }

  static Future<List<Inventario>> getAll() async {
    final db = await database;
    final maps = await db.query('inventario');

    return maps.map((e) => Inventario.fromMap(e)).toList();
  }
}
