import 'dart:convert'; // para usar jsonEncode
import 'package:http/http.dart' as http;

import '../classes/Artigo.dart';

Future<void> syncArtigos() async {
  try {
    // 1. Buscar artigos ainda não sincronizados
    List<Artigo> unsynced = await Artigo.getUnsyncedArtigos();

    if (unsynced.isEmpty) {
      print("Nenhum artigo para sincronizar");
      return;
    }

    // 2. Converter lista para JSON
    List<Map<String, dynamic>> artigosMap =
    unsynced.map((a) => a.toMap()).toList();

    String body = jsonEncode(artigosMap);

    print("JSON para enviar: $body");

    // 3. Enviar para a API remota
    final response = await http.post(
      Uri.parse("http://192.168.10.102:5021/api/Artigo/sync"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(unsynced.map((a) => a.toMap()).toList()),
    );

    print(response.statusCode);
    // 4. Tratar resposta
    if (response.statusCode == 200) {
      print("Artigos sincronizados com sucesso!");

      // Atualizar todos como sincronizados
      for (var artigo in unsynced) {
        artigo.isSynced = 1;
        //await Artigo.updateArtigo(artigo);
      }
    } else {
      print("Erro ao sincronizar: ${response.body}");
    }
  } catch (e) {
    print("Erro no sync: $e");
  }
}



Future<void> fetchAndStoreArtigos() async {
  try {
    final response = await http.get(Uri.parse("http://192.168.10.102:5021/api/Artigo"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      for (var item in data) {
        Artigo artigo = Artigo.fromMap(item);
        await Artigo.insertOrUpdate(artigo);
      }

      print("Artigos armazenados/atualizados localmente!");
    } else {
      print("Erro ao buscar artigos: ${response.body}");
    }
  } catch (e) {
    print("Erro: $e");
  }
}

