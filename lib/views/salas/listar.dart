import 'package:cibapp/views/salas/registar.dart';
import 'package:flutter/material.dart';

import '../../classes/Sala.dart';


class ListarSalas extends StatefulWidget {
  const ListarSalas({super.key});

  @override
  State<ListarSalas> createState() => _ListarSalasState();
}

class _ListarSalasState extends State<ListarSalas> {
  late Future<List<Sala>> _salasFuture;

  @override
  void initState() {
    super.initState();
    _carregarSalas();
  }

  void _carregarSalas() {
    setState(() {
      _salasFuture = Sala.getAllSalas();
    });
  }

  Future<void> _deletarSala(int id) async {
    await Sala.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sala removida com sucesso!")),
    );
    _carregarSalas();
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
                  title: const Text("Lista de Salas"),
                  backgroundColor: Colors.black54,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _carregarSalas,
                    )
                  ],
                ),
                Expanded(
                  child: FutureBuilder<List<Sala>>(
                    future: _salasFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Erro: ${snapshot.error}"));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text("Nenhuma sala encontrada.",
                                style: TextStyle(color: Colors.white)));
                      }

                      final salas = snapshot.data!;

                      return ListView.builder(
                        itemCount: salas.length,
                        itemBuilder: (context, index) {
                          final sala = salas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.meeting_room,
                                  color: Colors.blue),
                              title: Text("Sala ${sala.num_sala}"),
                              subtitle:
                              Text("Código: ${sala.codigo_barra}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  if (sala.id_sala != null) {
                                    _deletarSala(sala.id_sala!);
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




