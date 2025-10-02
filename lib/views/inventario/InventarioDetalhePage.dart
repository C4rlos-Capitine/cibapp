import 'package:flutter/material.dart';
import '../../classes/ArtigoInventario.dart';
import '../../classes/Artigo.dart';
import '../../classes/Inventario.dart';

class InventarioDetalhePage extends StatefulWidget {
  final Inventario inventario;

  const InventarioDetalhePage({Key? key, required this.inventario})
      : super(key: key);

  @override
  State<InventarioDetalhePage> createState() => _InventarioDetalhePageState();
}

class _InventarioDetalhePageState extends State<InventarioDetalhePage> {
  List<Artigo> artigos = [];

  @override
  void initState() {
    super.initState();
    carregarArtigos();
  }

  Future<void> carregarArtigos() async {
    final artigosInventario = await InventarioArtigo.getArtigosByInventario(
      widget.inventario.id_inventario!,
    );
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
              'assets/imagens/f-login__background.png', // a mesma imagem usada na tela anterior
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Camada de escurecimento translúcida
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

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
                : ListView.builder(
              itemCount: artigos.length,
              itemBuilder: (context, i) {
                final art = artigos[i];
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
                    subtitle: Text('Código: ${art.codigo_barra}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
