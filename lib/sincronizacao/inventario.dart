import 'dart:convert';
import 'package:http/http.dart' as http;
import '../classes/Inventario.dart';
import '../classes/ArtigoInventario.dart';

Future<bool> syncInventarios() async {
  bool resp = false;
  try {
    // 1️⃣ Buscar inventários ainda não sincronizados
    List<Inventario> unsynced = await Inventario.getUnsyncedInventarios();


    if (unsynced.isEmpty) {
      print("Nenhum inventário para sincronizar");
      return false;
    }

    // 2. Converter para JSON conforme o backend espera
    List<Map<String, dynamic>> inventariosMap =
    unsynced.map((inv) => inv.toMapForSync()).toList();

    String body = jsonEncode(inventariosMap);
    print("JSON para enviar: $body");

    // 3. Enviar à API remota
    final response = await http.post(
      Uri.parse("http://192.168.10.107:5021/api/Inventario/sync"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print(response.statusCode);

    // 4️⃣ Tratar resposta
    if (response.statusCode == 200) {
      print("Inventários sincronizados com sucesso!");

      // Atualizar todos como sincronizados localmente
      for (var inv in unsynced) {
        inv.isSynced = 1;
        await Inventario.insertOrUpdate(inv);
      }

      resp = true;
    } else {
      print("Erro ao sincronizar inventários: ${response.body}");
    }
  } catch (e) {
    print("Erro no sync de inventários: $e");
  }

  return resp;
}
Future<void> fetchAndStoreInventarios() async {
  try {
    final response = await http.get(
      Uri.parse("http://192.168.10.107:5021/api/Inventario"),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print("Dados brutos da API (Inventarios): $data");

      List<Inventario> inventarios = data.map((item) {
        return Inventario(
          id_inventario: item["id_inventario"] ?? "",
          id_sala: item["id_sala"] ?? "",
          nome_inventario: item["nome_inventario"]?.toString() ?? "",
          isSynced: item["isSynced"] ?? 0,
          data_inicio: item['data_inicio'] != null
              ? DateTime.tryParse(item['data_inicio'].toString())!
              : DateTime.now(), // ou algum valor padrão

          lastUpdated: item['lastUpdated'],
        );
      }).toList();

      // Armazenar ou atualizar localmente no SQLite
      for (var inv in inventarios) {
        await Inventario.insertOrUpdate(inv);
      }

      print("Inventários armazenados/atualizados localmente!");
    } else {
      print("Erro ao buscar inventários: ${response.body}");
    }
  } catch (e) {
    print("Erro ao sincronizar inventários: $e");
  }
}

Future<bool> syncInventarioArtigos() async {
  bool resp = false;
  try {
    List<InventarioArtigo> unsynced = await InventarioArtigo.getUnsyncedInventarioArtigos();

    if (unsynced.isEmpty) {
      print("Nenhum item de inventário para sincronizar");
      return false;
    }

    String body = jsonEncode(unsynced.map((i) => i.toMap()).toList());
    print("JSON para enviar: $body");

    final response = await http.post(
      Uri.parse("http://192.168.10.107:5021/api/InventarioArtigo/sync"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      print("Itens de inventário sincronizados com sucesso!");

      for (var item in unsynced) {
        item.isSynced = 1;
        await InventarioArtigo.insertOrUpdate(item);
      }

      resp = true;
    } else {
      print("Erro ao sincronizar inventarioArtigo: ${response.body}");
    }
  } catch (e) {
    print("Erro no sync de InventarioArtigo: $e");
  }

  return resp;
}

Future<void> fetchAndStoreInventarioArtigos() async {
  try {
    final response = await http.get(
      Uri.parse("http://192.168.10.107:5021/api/InventarioArtigo"),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print("Dados brutos da API (InventarioArtigo): $data");

      List<InventarioArtigo> items = data.map((item) {
        return InventarioArtigo(
          id_inventario_artigo: item["id_inventario_artigo"] ?? "",
          id_inventario: item["id_inventario"] ?? "",
          id_artigo: item["id_artigo"] ?? "",
          lastUpdated: item["lastUpdated"] != null
              ? DateTime.tryParse(item["lastUpdated"].toString())
              : null,
          isSynced: item["isSynced"] ?? 0,
        );
      }).toList();

      for (var item in items) {
        await InventarioArtigo.insertOrUpdate(item);
      }

      print("Itens de inventário armazenados/atualizados localmente!");
    } else {
      print("Erro ao buscar InventarioArtigo: ${response.body}");
    }
  } catch (e) {
    print("Erro ao sincronizar InventarioArtigo: $e");
  }
}

