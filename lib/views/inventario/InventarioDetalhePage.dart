import 'dart:convert';

import 'package:flutter/material.dart';
import '../../classes/ArtigoInventario.dart';
import '../../classes/Artigo.dart';
import '../../classes/Inventario.dart';
import '../../classes/Sala.dart';

class InventarioDetalhePage extends StatefulWidget {
  final Inventario inventario;

  const InventarioDetalhePage({Key? key, required this.inventario})
      : super(key: key);

  @override
  State<InventarioDetalhePage> createState() => _InventarioDetalhePageState();
}

class _InventarioDetalhePageState extends State<InventarioDetalhePage> {
  List<Artigo> artigos = [];
  Sala? sala;
  @override
  void initState() {
    super.initState();
    carregarArtigos();
    getSala();
  }

  Future<void>getSala()async {
    Sala? _sala = await Sala.getByUniqueId(widget.inventario.unique_id_sala);
    setState(() {
      sala = _sala;
    });
  }

  Future<void> carregarArtigos() async {
    final artigosInventario = await InventarioArtigo.getArtigosByInventario(
      widget.inventario.id_inventario!,
    );
    //print(jsonEncode(artigosInventario));
    setState(() {
      artigos = artigosInventario;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.inventario.nome_inventario),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Stack(
        children: [
          /// 🔹 Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'assets/imagens/f-login__background.png',
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Camada translúcida
          Container(color: Colors.black.withOpacity(0.4)),

          /// 🔹 Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(12),
            child: artigos.isEmpty
                ? const Center(
              child: Text(
                'Nenhum artigo associado.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
                : ListView(
              children: [
                /// 🔹 Card da sala
                Card(
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.meeting_room, color: Colors.blue),
                    title: Text(
                      sala!.num_sala, // 🟦 ex: “Sala 203”
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                          'Última atualização: ${sala!.lastUpdated}',
                    ),
                    isThreeLine: true,
                  ),
                ),

                /// 🔹 Lista de artigos
                ...artigos.map((art) {
                  return Card(
                    color: Colors.white.withOpacity(0.85),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.qr_code_2),
                      title: Text(
                        art.nome_artigo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Código: ${art.codigo_barra}\nID:',
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
