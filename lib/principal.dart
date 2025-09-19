import 'package:cibapp/artigos.dart';
import 'package:cibapp/inicio.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {

  String? _salaSelecionada;

  final List<String> _salas = [
    'Sala 101 - Matemática',
    'Sala 202 - Física',
    'Sala 303 - Programação',
    'Sala 404 - Robótica',
    'Sala 505 - Design Gráfico',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/imagens/f-login__background.png"),
                fit: BoxFit.cover,
                /*colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.70), // Deixa o conteúdo legível
                  BlendMode.lighten,
                ),*/
              ),
            ),
          ),

          // 🔹 Foreground content (com scroll e padding)
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40), // espaço para status bar
                Text(
                  "Selecione a Sala",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Sala",
                    hintText: "Escolha uma sala",
                    labelStyle: TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  value: _salaSelecionada,
                  items: _salas.map((String sala) {
                    return DropdownMenuItem<String>(
                      value: sala,
                      child: Text(sala),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _salaSelecionada = newValue!;
                    });
                  },
                ),

                SizedBox(height: 20),
                Text(
                  "Informações da Sala",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),

                // Cards (com fundo branco para legibilidade)
                Card(
                  color: Colors.white.withOpacity(0.9),
                  child: ListTile(
                    leading: Icon(Icons.people, color: Colors.blue),
                    title: Text("Capacidade"),
                    subtitle: Text("30 alunos"),
                  ),
                ),
                Card(
                  color: Colors.white.withOpacity(0.9),
                  child: ListTile(
                    leading: Icon(Icons.computer, color: Colors.blue),
                    title: Text("Equipamentos"),
                    subtitle: Text("Projetor, Computadores, Quadro Digital"),
                    onTap: (){
                      Navigator.push(
                          context,
                          //MaterialPageRoute(builder: (context) => Principal(user_logged: user_logged)),
                          MaterialPageRoute(builder: (context)=> Artigos())
                      );
                    },
                  ),
                ),
                Card(
                  color: Colors.white.withOpacity(0.9),
                  child: ListTile(
                    leading: Icon(Icons.access_time, color: Colors.blue),
                    title: Text("Horário de Uso"),
                    subtitle: Text("08:00 - 12:00 | 14:00 - 18:00"),
                  ),
                ),
                Card(
                  color: Colors.white.withOpacity(0.9),
                  child: ListTile(
                    leading: Icon(Icons.inventory, color: Colors.blue),
                    title: Text("Último Inventário"),
                    subtitle: Text(DateTime.now().toString()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
