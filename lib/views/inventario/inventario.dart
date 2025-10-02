import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../classes/Sala.dart';
import '../../classes/Artigo.dart';
import '../../classes/ArtigoInventario.dart';
import '../../classes/Inventario.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({Key? key}) : super(key: key);

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final nomeCtrl = TextEditingController();
  Sala? salaSelecionada;
  List<Artigo> artigosLidos = [];

  /// 🔹 Lê o código de barras da sala
  Future<void> lerSala() async {
    var result = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Leitura da Sala',
        centerTitle: true,
        enableBackButton: true,
      ),
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
    );

    if (result == null || result.isEmpty || result == "-1") return;

    final sala = await Sala.getByCodigoBarra(result);

    if (sala != null) {
      setState(() {
        salaSelecionada = sala;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sala encontrada: ${sala.num_sala}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sala não encontrada: $result')),
      );
    }
  }

  /// 🔹 Lê o código de barras de um artigo e adiciona à lista
  Future<void> lerCodigoBarra() async {
    if (salaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leia primeiro o código da sala!')),
      );
      return;
    }

    var result = await SimpleBarcodeScanner.scanBarcode(
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

    final artigo = await Artigo.getByCodigoBarra(result);

    if (artigo != null) {
      if (!artigosLidos.any((a) => a.codigo_barra == artigo.codigo_barra)) {
        setState(() {
          artigosLidos.add(artigo);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artigo já adicionado!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artigo não encontrado: $result')),
      );
    }
  }

  /// 🔹 Grava o inventário e os artigos associados
  Future<void> gravarInventario() async {
    if (salaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma sala selecionada!')),
      );
      return;
    }

    if (nomeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do inventário!')),
      );
      return;
    }

    if (artigosLidos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum artigo adicionado!')),
      );
      return;
    }

    // 1️⃣ Cria o inventário com a sala associada
    final inventario = Inventario(
      id_sala: salaSelecionada!.id_sala!,
      nome_inventario: nomeCtrl.text,
      data_inicio: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    final id = await Inventario.insert(inventario);

    // 2️⃣ Associa artigos ao inventário
    for (var artigo in artigosLidos) {
      await InventarioArtigo.insert(
        InventarioArtigo(
          id_inventario: id!,
          id_artigo: artigo.id_artigo!,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inventário gravado com sucesso!')),
    );

    // 3️⃣ Limpa tudo
    setState(() {
      nomeCtrl.clear();
      salaSelecionada = null;
      artigosLidos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registo de Inventário'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Stack(
        children: [
          /// 🔹 Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'assets/imagens/f-login__background.png', // coloque sua imagem em assets/images/
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Camada semitransparente para legibilidade
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          /// 🔹 Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔹 Campo nome inventário
                  TextField(
                    controller: nomeCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nome do Inventário',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Leitura da sala
                  ElevatedButton.icon(
                    onPressed: lerSala,
                    icon: const Icon(Icons.meeting_room_outlined),
                    label: const Text('Ler Código da Sala'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  if (salaSelecionada != null) ...[
                    const SizedBox(height: 10),
                    Card(
                      color: Colors.white.withOpacity(0.85),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.meeting_room),
                        title: Text(salaSelecionada!.num_sala),
                        subtitle: Text('Código: ${salaSelecionada!.codigo_barra}'),
                      ),
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: lerCodigoBarra,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Ler Código de Barras (Artigos)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 🔹 Lista de artigos lidos
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: artigosLidos.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('Nenhum artigo adicionado ainda.')),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: artigosLidos.length,
                      itemBuilder: (context, i) {
                        final artigo = artigosLidos[i];
                        return Card(
                          color: Colors.grey[100],
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.inventory_2),
                            title: Text(artigo.nome_artigo),
                            subtitle:
                            Text('Código: ${artigo.codigo_barra}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  artigosLidos.removeAt(i);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Botão para gravar
                  ElevatedButton.icon(
                    onPressed: gravarInventario,
                    icon: const Icon(Icons.save),
                    label: const Text('Gravar Inventário'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
