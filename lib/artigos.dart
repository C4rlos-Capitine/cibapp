import 'package:flutter/material.dart';

class Artigos extends StatefulWidget {
  const Artigos({super.key});

  @override
  State<Artigos> createState() => _ArtigosState();
}

class _ArtigosState extends State<Artigos> {
  // 🔹 Lista fictícia de artigos da sala
  final List<String> _artigosDaSala = [
    'Quadro Branco Interativo',
    'Projetor Epson X500',
    'Notebook Dell Latitude',
    'Kit Robótica LEGO Mindstorms',
    'Impressora 3D Ender 3 V2',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Fundo com imagem
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/imagens/f-login__background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 Conteúdo com padding e scroll
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Artigos da Sala",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // 🔹 Lista de cards
                  ..._artigosDaSala.map((artigo) {
                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      child: ListTile(
                        leading: Icon(Icons.inventory, color: Colors.blue),
                        title: Text(artigo),
                        subtitle: Text("Código: 123456"), // dado fictício
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
