import 'dart:convert';
import 'package:http/http.dart' as http;

import '../classes/Sala.dart';

Future<void> syncSalas() async {
  try {
    // 1. Buscar salas ainda não sincronizadas
    List<Sala> unsynced = await Sala.getUnsyncedSalas();

    if (unsynced.isEmpty) {
      print("Nenhuma sala para sincronizar");
      return;
    }

    // 2. Converter lista para JSON
    List<Map<String, dynamic>> salasMap =
    unsynced.map((s) => s.toMap()).toList();

    String body = jsonEncode(salasMap);

    print("JSON para enviar: $body");

    // 3. Enviar para a API remota
    final response = await http.post(
      Uri.parse("http://192.168.10.102:5021/api/Sala/sync"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(unsynced.map((a) => a.toMap()).toList()),
    );
    print(response.statusCode);
    // 4. Tratar resposta
    if (response.statusCode == 200) {
      print("Salas sincronizadas com sucesso!");

      // Atualizar todas como sincronizadas
      for (var sala in unsynced) {
        sala.isSynced = 1;
        //await Sala.updateSala(sala);
      }
    } else {
      print("Erro ao sincronizar: ${response.body}");
    }
  } catch (e) {
    print("Erro no sync: $e");
  }
}



Future<void> fetchAndStoreSalas() async {
  try {
    final response = await http.get(Uri.parse("http://192.168.10.102:5021/api/Sala"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      for (var item in data) {
        Sala sala = Sala.fromMap(item);
        await Sala.insertOrUpdate(sala);
      }

      print("Salas armazenadas/atualizadas localmente!");
    } else {
      print("Erro ao buscar salas: ${response.body}");
    }
  } catch (e) {
    print("Erro: $e");
  }
}
