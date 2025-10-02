import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../classes/Artigo.dart';
import '../../classes/Sala.dart';

class ArtigosPorSala extends StatefulWidget {
  const ArtigosPorSala({super.key});

  @override
  State<ArtigosPorSala> createState() => _ArtigosPorSalaState();
}

class _ArtigosPorSalaState extends State<ArtigosPorSala> {
  Sala? salaSelecionada;
  Future<List<Artigo>>? _artigosFuture;

  /// Escanear código da sala
  Future<void> _scanSala() async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
    );

    if (res is String && res != "-1") {
      Sala? sala = await Sala.getByCodigoBarra(res);

      if (sala != null) {
        setState(() {
          salaSelecionada = sala;
          _artigosFuture = Artigo.getBySala(sala.id_sala!);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sala não encontrada.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Fundo com imagem
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/imagens/f-login__background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 Conteúdo
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    salaSelecionada != null
                        ? "Artigos da Sala ${salaSelecionada!.num_sala}"
                        : "Artigos por Sala",
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner,
                          color: Colors.white),
                      onPressed: _scanSala,
                    ),
                  ],
                ),

                // 🔹 Lista de artigos
                Expanded(
                  child: _artigosFuture == null
                      ? const Center(
                    child: Text("Escaneie o código de uma sala.",
                        style: TextStyle(color: Colors.white)),
                  )
                      : FutureBuilder<List<Artigo>>(
                    future: _artigosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                            child: Text("Erro: ${snapshot.error}"));
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text("Nenhum artigo encontrado.",
                                style: TextStyle(color: Colors.white)));
                      }

                      final artigos = snapshot.data!;

                      return ListView.builder(
                        itemCount: artigos.length,
                        itemBuilder: (context, index) {
                          final artigo = artigos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.inventory,
                                  color: Colors.green),
                              title: Text(artigo.nome_artigo),
                              subtitle: Text(
                                  "Nº: ${artigo.num_artigo} | Código: ${artigo.codigo_barra}"),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanSala,
        child: const Icon(Icons.qr_code),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
