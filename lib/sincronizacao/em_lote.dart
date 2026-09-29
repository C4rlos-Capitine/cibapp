import 'dart:convert'; // para usar jsonEncode
import 'package:http/http.dart' as http;

import '../classes/Artigo.dart';
import '../classes/ArtigoInventario.dart';
import '../classes/Inventario.dart';
import '../classes/Sala.dart';
import '../config/Network.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> EnviarEmLote() async {
  bool return_val = false;
  // 1️⃣ Buscar dados locais
  List<Sala> salas = await Sala.getAllSalas();
  List<Map<String, dynamic>> salasMap = salas.map((s) => s.toMapToServer()).toList();

  List<Artigo> artigos = await Artigo.getAllArtigos();
  List<Map<String, dynamic>> artigosMap = artigos.map((a) => a.toMapToServer()).toList();

  List<Inventario> inventarios = await Inventario.getAll();
  List<Map<String, dynamic>> inventariosMap = inventarios.map((inv) => inv.toServerMap()).toList();

  List<InventarioArtigo> itensInventario = await InventarioArtigo.getAll();
  List<Map<String, dynamic>> itensInventarioMap = itensInventario.map((i) => i.toServerMap2()).toList();

  // 2️⃣ Montar payload completo
  final Map<String, dynamic> payload = {
    "salas": salasMap,
    "artigos": artigosMap,
    "inventarios": inventariosMap,
    "inventarioArtigos": itensInventarioMap,
  };

  print("Data to send: ${jsonEncode(payload)}");

  // 3️⃣ Enviar para a API
  final url = Uri.parse('http://$address_port/api/SyncAll/sync'); // ⚠️ ajusta o endereço da tua API
  final headers = {
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('✅ Dados enviados com sucesso');
      return_val = true;
    } else {
      print('❌ Falha ao enviar dados: ${response.statusCode}');
      print('Resposta: ${response.body}');
    }
  } catch (e) {
    print('⚠️ Erro ao enviar dados: $e');
  }
  return return_val;
}
