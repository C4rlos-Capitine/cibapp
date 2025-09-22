import 'package:cibapp/views/artigos/listar.dart';
import 'package:cibapp/views/salas/listar.dart';
import 'package:flutter/material.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  TextEditingController _nomeArtigo = TextEditingController();
  String? _artigoSelecionado;

  final List<String> _artigos = [
    'Introdução à Inteligência Artificial',
    'Técnicas de Machine Learning',
    'Flutter para Iniciantes',
    'Design de Interfaces Modernas',
    'O Futuro da Computação Quântica',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black54,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
        ),
        title: const Text(
          "Início",
          style: TextStyle(color: Colors.white),
        ),
      ),
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
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.meeting_room, color: Colors.blue),
                      title: const Text("Salas"),
                      subtitle: const Text("Clique para ver os ativos de cada sala"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ListarSalas()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.green),
                      title: const Text("Artigos"),
                      subtitle: const Text("Clique para ver os ativos"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ListarArtigos()),
                        );
                      },
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
