import 'dart:convert';
import 'package:http/http.dart' as http;

import '../classes/Sala.dart';
import 'package:uuid/uuid.dart';

import '../config/Network.dart';

//import '../config/Network.dart';
//const address_port = "192.168.10.111:5021";
//const address_port = "192.168.10.112:5021";
Future<bool> syncSalas() async {
  bool resp = false;
  try {
    // 1. Buscar salas ainda não sincronizadas
    List<Sala> unsynced = await Sala.getAllSalas();

    if (unsynced.isEmpty) {
      print("Nenhuma sala para sincronizar");
      return false;
    }

    // 1. Converter lista para JSON
    List<Map<String, dynamic>> salasMap =
    unsynced.map((s) => s.toMapToServer()).toList();

    // 2. Estruturar o JSON para incluir a chave "salas"
    String body = jsonEncode({"salas": salasMap});

    print("JSON para enviar: $body");

    // 3. Enviar para a API remota
    final response = await http.post(
      Uri.parse("http://$address_port/api/Sala/sync"),
      headers: {"Content-Type": "application/json"},
      body: body, // Use o corpo estruturado corretamente
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


Future<bool> fetchAndStoreSalas() async {
  bool return_value = false;
  try {
   // final response = await http.get(Uri.parse("http://192.168.10.120:5021/api/Sala"));
    final response = await http.get(Uri.parse("http://$address_port/api/Sala"));
    print(response);
    var uuid = Uuid();
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print("Dados brutos da API: $data");

      // Converter cada item antes de criar o modelo
      List<Sala> salas = data.map((item) {
        // Conversões seguras para evitar erros de tipo
        final idSala = item["id_sala"] ?? 0;
        final codigoBarra = item["codigo_barra"]?.toString() ?? "";
        final numSala = item["num_sala"]?.toString() ?? "";
        final isSynced = (item["isSynced"] == true) ? 1 : 0; // Aceita bool ou int isSynced == 1 || isSynced == true
        final lastUpdated = item["lastUpdated"] != null ? DateTime.tryParse(item["lastUpdated"].toString()): null;

        return Sala(
          codigo_barra: codigoBarra,
          num_sala: numSala,
          isSynced: isSynced,
          lastUpdated: lastUpdated,
          unique_id: idSala,
        );
      }).toList();

      // Armazenar ou atualizar no SQLite
      for (var sala in salas) {
        await Sala.insertOrUpdate(sala);
      }

      print("Salas armazenadas/atualizadas localmente!");
      return_value = true;
    } else {
      print("Erro ao buscar salas: ${response.body}");
    }
  } catch (e) {
    print("Erro ao sincronizar salas: $e");
  }
  return return_value;
}

Future<Sala?> fetchSingleFromServer(String codigoBarra) async {
try {
final response = await http.get(
Uri.parse("http://$address_port/api/Sala/getSingle?code=$codigoBarra"),
headers: {"Content-Type": "application/json"},
);

if (response.statusCode != 200) {
print("Erro ao buscar sala: ${response.body}");
return null;
}

final item = jsonDecode(response.body);

return Sala(
codigo_barra: item["codigo_barra"]?.toString() ?? "",
num_sala: item["num_sala"]?.toString() ?? "",
unique_id: item["id_sala"],
isSynced: (item["isSynced"] == true) ? 1 : 0,
lastUpdated: item["lastUpdated"] != null
? DateTime.tryParse(item["lastUpdated"].toString())
    : DateTime.now(),
);
} catch (e) {
print("Erro fetchSingleFromServer Sala: $e");
return null;
}
}


Future<Sala?> baixarEGuardarSala(String codigoBarra) async {
  try {
    final response = await http.get(
      Uri.parse("http://$address_port/api/Sala/getSingle?code=$codigoBarra"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(response.body);
      if (data == null) return null;

      final isSynced = (data["isSynced"] == true || data["isSynced"] == 1) ? 1 : 0;
      final lastUpdated = data["lastUpdated"] != null
          ? DateTime.tryParse(data["lastUpdated"].toString())
          : null;

      final sala = Sala(
        unique_id: data["id_sala"],
        codigo_barra: data["codigo_barra"]?.toString() ?? "",
        num_sala: data["num_sala"]?.toString() ?? "",
        isSynced: isSynced,
        lastUpdated: lastUpdated,
      );

      // 🔹 Salva ou atualiza no SQLite local
      await Sala.insertOrUpdate(sala);
      print("✅ Sala ${sala.num_sala} salva localmente.");

      return sala;
    } else {
      print("Erro ao buscar sala: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Erro ao baixar sala: $e");
    return null;
  }
}



Future<List<Sala>> getSalasSemEtiqueta()async{
  List<Sala> salas = [];
  final response = await http.get(Uri.parse("http://$address_port/api/Sala"));
  print(response);
  print(jsonDecode(response.body));
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    print("Dados brutos da API: $data");

    // Converter cada item antes de criar o modelo
    salas = data.map((item) {
      // Conversões seguras para evitar erros de tipo
      final idSala = item["id_sala"] ?? 0;
      final codigoBarra = item["codigo_barra"]?.toString() ?? "";
      final numSala = item["num_sala"]?.toString() ?? "";
      final isSynced = (item["isSynced"] == true) ? 1 : 0; // Aceita bool ou int isSynced == 1 || isSynced == true
      final lastUpdated = item["lastUpdated"] != null ? DateTime.tryParse(item["lastUpdated"].toString()): null;



      return Sala(
        codigo_barra: codigoBarra,
        num_sala: numSala,
        isSynced: isSynced,
        lastUpdated: lastUpdated,
        unique_id: idSala,
      );
    }).toList();

    // Armazenar ou atualizar no SQLite
    for (var sala in salas) {
      await Sala.insertOrUpdate(sala);
    }
  }
  return await Sala.getAllSalas();
}
