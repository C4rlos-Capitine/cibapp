import 'dart:convert';
import 'package:http/http.dart' as http;

import '../classes/Sala.dart';

Future<bool> syncSalas() async {
  bool resp = false;
  try {
    // 1. Buscar salas ainda não sincronizadas
    List<Sala> unsynced = await Sala.getUnsyncedSalas();

    if (unsynced.isEmpty) {
      print("Nenhuma sala para sincronizar");
      return false;
    }

    // 2. Converter lista para JSON
    List<Map<String, dynamic>> salasMap =
    unsynced.map((s) => s.toMap()).toList();

    String body = jsonEncode(salasMap);

    print("JSON para enviar: $body");

    // 3. Enviar para a API remota
    final response = await http.post(
      Uri.parse("http://5.189.138.20:8070/api/Sala/sync"),
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
      resp = true;
    } else {
      print("Erro ao sincronizar: ${response.body}");
    }
  } catch (e) {
    print("Erro no sync: $e");
  }
  return resp;
}


Future<void> fetchAndStoreSalas() async {
  try {
    final response = await http.get(Uri.parse("http://5.189.138.20:8070/api/Sala"));
    //final response = await http.get(Uri.parse("http://192.168.10.118:5021/api/Sala"));
    print(response);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print("Dados brutos da API: $data");

      // Converter cada item antes de criar o modelo
      List<Sala> salas = data.map((item) {
        // Conversões seguras para evitar erros de tipo
        final idSala = item["id_Sala"] ?? 0;
        final codigoBarra = item["codigo_Barra"]?.toString() ?? "";
        final numSala = item["num_Sala"]?.toString() ?? "";
        final isSynced = item["isSynced"]; // Aceita bool ou int
        final lastUpdated = item["lastUpdated"] != null
            ? DateTime.tryParse(item["lastUpdated"].toString())
            : null;

        return Sala(

          codigo_barra: codigoBarra,
          num_sala: numSala,
          isSynced: isSynced,
          lastUpdated: lastUpdated,
        );
      }).toList();

      // Armazenar ou atualizar no SQLite
      for (var sala in salas) {
        await Sala.insertOrUpdate(sala);
      }

      print("Salas armazenadas/atualizadas localmente!");
    } else {
      print("Erro ao buscar salas: ${response.body}");
    }
  } catch (e) {
    print("Erro ao sincronizar salas: $e");
  }
}
