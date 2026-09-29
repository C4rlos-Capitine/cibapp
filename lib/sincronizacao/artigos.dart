import 'dart:convert'; // para usar jsonEncode
import 'package:http/http.dart' as http;

import '../classes/Artigo.dart';
import '../config/Network.dart';

Future<bool> syncArtigos() async {
  bool resp = false;
  try {
    // 1. Buscar artigos ainda não sincronizados
    List<Artigo> unsynced = await Artigo.getAllArtigos();

    if (unsynced.isEmpty) {
      print("Nenhum artigo para sincronizar");
      return false;
    }

    // 1. Converter lista para JSON
    List<Map<String, dynamic>> artigosMap =
    unsynced.map((a) => a.toMapToServer()).toList();

    // 2. Estruturar o JSON para incluir a chave "artigos"
    String body = jsonEncode({"artigos": artigosMap});

    print("JSON para enviar: $body");

    // 3. Enviar para a API remota
    final response = await http.post(
      Uri.parse("http://$address_port/api/Artigo/sync"),
      headers: {"Content-Type": "application/json"},
      body: body,  // Envie o corpo estruturado corretamente
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
      resp = true;
    } else {
      print("Erro ao sincronizar: ${response.body}");
    }
  } catch (e) {
    print("Erro no sync: $e");
  }
  return resp;
}



Future<bool> fetchAndStoreArtigos() async {
  bool return_val = false;
  try {
    final response = await http.get(Uri.parse("http://$address_port/api/Artigo"));
    //final response = await http.get(Uri.parse("http://192.168.10.118:5021/api/Artigo"));
//print(response);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
print(data);
      for (var item in data) {
        Artigo artigo = Artigo.fromMapAPI(item);
        await Artigo.insertOrUpdate(artigo);
      }

      print("Artigos armazenados/atualizados localmente!");
      return_val = true;
    } else {
      print("Erro ao buscar artigos: ${response.body}");
    }
  } catch (e) {
    print("Erro: $e");
  }
  return return_val;
}

Future<Artigo?> baixarEGuardarArtigo(String codigoBarra) async {
  try {
      final url = Uri.parse("http://$address_port/api/Artigo/getSingle?code=$codigoBarra");
      final response = await http.get(url);
      print("artigo baixado: ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      Artigo artigo = Artigo.fromMapAPI(json);

      await Artigo.insertOrUpdate(artigo);
      //Artigo art = await Artigo.getByCodigoBarra(artigo.codigo_barra);
      print("✅ Artigo '${artigo.nome_artigo} ${artigo.num_artigo}' salvo localmente.");
      return artigo;
    } else {
    print("⚠️ Artigo não encontrado (${response.statusCode})");
      return null;
    }
  } catch (e) {
  print("❌ Erro ao baixar artigo: $e");
  return null;
  }
}
