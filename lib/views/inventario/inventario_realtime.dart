import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../classes/Artigo.dart';
import '../../classes/Sala.dart';
import '../../classes/Verificacao.dart';
import '../../config/Network.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class realTimeInventory extends StatefulWidget {
  realTimeInventory(
      {required this.id_inventario_unique, required this.nome_inventario});
  //late String codinventario;
  late String id_inventario_unique;
  late String nome_inventario;
  @override
  State<realTimeInventory> createState() => _realTimeInventoryState();
}

class _realTimeInventoryState extends State<realTimeInventory> {
  List<Artigo> artigosLidos = [];
  bool _isLoading = false;

  initState() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Check network status and wait for the result
    NetworkCheckResponse networkStatus = await isConnected();
    bool serverStatus = await checkServer(address, port);
    if (!networkStatus.state) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(networkStatus.mesg)),
      );
    } else if (!serverStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Serviço indisponível")),
      );
    } else {
      // Network and server are available, proceed with data initialization
      //await fetchAndStoreInventarioArtigos();
    }
    SnackBar snackBar = SnackBar(content: Text(networkStatus.mesg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventário: ${widget.nome_inventario}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: lerArtigo,
          )
        ],
      ),
      body: Stack(
        children: [
          /// 🔹 Fundo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/imagens/HCB_app-background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🔹 Lista de artigos
          artigosLidos.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhum artigo lido",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: artigosLidos.length,
                  itemBuilder: (context, i) {
                    final art = artigosLidos[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2),
                        title: Text(art.nome_artigo),
                        subtitle: Text(
                          "Código: ${art.codigo_barra}\nRef: ${art.num_artigo}",
                        ),
                      ),
                    );
                  },
                ),

          /// 🔹 OVERLAY DE LOADING
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      "Processando...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> lerArtigo() async {
    if (_isLoading) return; // evita múltiplos scans

    final result = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Leitura de Artigos',
        centerTitle: true,
        enableBackButton: true,
      ),
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
    );

    if (result == null || result.isEmpty || result == "-1") return;

    setState(() => _isLoading = true);

    try {
      Artigo? artigo;

      final url = Uri.parse(
        "http://$address_port/api/Artigo/updateAsset?numVelho=$result&codListt=${widget.id_inventario_unique}",
      );
      print(result);
      final response =
          await http.post(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artigo não encontrado: $result')),
        );
        return;
      }
      if (response.statusCode != 500) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erro ao processar o artigo: ${response.statusCode}')),
        );
        return;
      }

      final body = jsonDecode(response.body);

      if (body["artigo"] == null) {
        throw Exception("Resposta inválida do servidor");
      }

      //artigo = Artigo.fromServerMap(body["artigo"]);
      var verificacao = Verificacao.fromServerMap(body["verificacao"]);
      await Verificacao.insertOrUpdate(verificacao);
      //await Artigo.insertOrUpdate(artigo);

      if (artigosLidos.any((a) => a.codigo_barra == verificacao!.num_artigo)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artigo já adicionado')),
        );
        return;
      }

      setState(() {
        artigosLidos.add(artigo!);
      });
    } on TimeoutException {
      Verificacao verificacao = Verificacao(
        id_inventario: widget.id_inventario_unique,
        num_artigo: result,
        nome_artigo: "Desconhecido",
        data_registo: DateTime.now(),
        isSynced: 0,
      );
      Verificacao.insertOrUpdate(verificacao);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tempo limite excedido. Não foi possível contactar o servidor.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao ler artigo: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
