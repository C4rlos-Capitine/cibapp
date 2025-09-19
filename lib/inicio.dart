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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black,),
        )
      ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Optional for better alignment
            children: [
              Text("Dados do Artigo"),

              SizedBox(height: 10), // Spacing between elements

              TextFormField(
                controller: _nomeArtigo,
                autocorrect: true,
                decoration: InputDecoration(
                  labelText: "Nome do Artigo",
                  hintText: "Nome do artigo",
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),

              SizedBox(height: 20), // Spacing before dropdown
// Dentro do build()
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Artigos",
                  hintText: "Selecione um artigo",
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                value: _artigoSelecionado,
                items: _artigos.map((String artigo) {
                  return DropdownMenuItem<String>(
                    value: artigo,
                    child: Text(artigo),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _artigoSelecionado = newValue!;
                  });
                },
              ),

            ],
          ),

        )
    );
  }
}
