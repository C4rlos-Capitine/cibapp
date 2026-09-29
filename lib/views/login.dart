import 'package:cibapp/inicio.dart';
import 'package:flutter/material.dart';
import 'package:cibapp/classes/Inventario.dart';
import 'package:cibapp/classes/Verificacao.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  initState() {
    super.initState();
    _testData();
    _testeVerificacao();
  }

  Future<void> _testData() async {
    List<Inventario> inventarios = await Inventario.getAll();
    print("Inventários encontrados: ${inventarios.length}");
    for (var inventario in inventarios) {
      print(
          "ID: ${inventario.id_inventario}, Nome: ${inventario.nome_inventario}");
    }
  }

  Future<void> _testeVerificacao() async {
    Verificacao.openDb();
    List<Verificacao> inventarios = await Verificacao.getAll();
    if (inventarios.isNotEmpty) {
      Verificacao verificacao = inventarios.first;
      print("count verificacao: ${inventarios.length}");
    } else {
      print("Nenhum inventário encontrado.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Background
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/imagens/HCB_app-background.png",
            ),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              color: Colors.white.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    const Text(
                      "Bem-vindo",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Entre na sua conta",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Utilizador
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Nome de utilizador",
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue[900]!),
                        ),
                        focusColor: Colors.blue[900],
                        hoverColor: Colors.blue[900],
                        iconColor: Colors.blue[900],
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue[900]!, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[900]!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Senha
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Senha",
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue[900]!),
                        ),
                        focusColor: Colors.blue[900],
                        hoverColor: Colors.blue[900],
                        iconColor: Colors.blue[900],
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue[900]!, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue[900]!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Botão
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // lógica de login aqui
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Inicio()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blue[900]),
                        child: const Text(
                          "Entrar",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
