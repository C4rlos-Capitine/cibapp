import 'package:cibapp/views/artigos/registar.dart';
import 'package:flutter/material.dart';

import '../../classes/Artigo.dart';
import '../salas/registar.dart';


class ListarArtigos extends StatefulWidget {
  const ListarArtigos({super.key});

  @override
  State<ListarArtigos> createState() => _ListarArtigosState();
}

class _ListarArtigosState extends State<ListarArtigos> {
  late Future<List<Artigo>> _artigosFuture;

  @override
  void initState() {
    super.initState();
    _carregarArtigos();
  }

  void _carregarArtigos() {
    setState(() {
      _artigosFuture = Artigo.getAllArtigos();
    });
  }

  Future<void> _deletarArtigo(int id) async {
    await Artigo.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Artigo removido com sucesso!")),
    );
    _carregarArtigos();
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
                  title: const Text("Lista de Artigos"),
                  backgroundColor: Colors.black54,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _carregarArtigos,
                    )
                  ],
                ),
                Expanded(
                  child: FutureBuilder<List<Artigo>>(
                    future: _artigosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Erro: ${snapshot.error}"));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                                  "Nº: ${artigo.num_artigo} | Sala: ${artigo.id_sala}\nCódigo: ${artigo.codigo_barra}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  if (artigo.id_artigo != null) {
                                    _deletarArtigo(artigo.id_artigo!);
                                  }
                                },
                              ),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegistarSala()),
          ).then((_){

          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, // Customize as needed
      ),
    );
  }
}
