
import 'package:flutter/material.dart';

import '../sincronizacao/artigos.dart';
import '../sincronizacao/salas.dart';


class sync_screen extends StatefulWidget {
  const sync_screen({super.key});

  @override
  State<sync_screen> createState() => _sync_screenState();
}

class _sync_screenState extends State<sync_screen> {
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
                      leading: const Icon(Icons.sync, color: Colors.green),
                      title: const Text("Sincronização Salas"),
                      subtitle: const Text("Clique para fazer upload "),
                      onTap: () async {
                      bool resp = await syncSalas();
                      if(resp==true){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Salas sincronizadas com sucesso',
                              style: TextStyle(color: Colors.blue[900]),
                            ),
                            backgroundColor:
                            Color.fromARGB(255, 55, 189, 26),
                          ),
                        );
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Não nada por actualizar',
                              style: TextStyle(color: Colors.blue[900]),
                            ),
                            backgroundColor:
                            Color.fromARGB(255, 235, 65, 3),
                          ),
                        );
                      }
                      },
                    ),
                  ),
                  SizedBox(height: 10,),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.sync, color: Colors.green),
                      title: const Text("Sincronização Ativos"),
                      subtitle: const Text("Clique para fazer upload "),
                      onTap: () async {
                        bool resp = await syncArtigos();
                        if(resp==true){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ativos sincronizadas com sucesso',
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                              backgroundColor:
                              Color.fromARGB(255, 55, 189, 26),
                            ),
                          );
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Não nada por actualizar',
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                              backgroundColor:
                              Color.fromARGB(255, 235, 65, 3),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 10,),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.sync, color: Colors.green),
                      title: const Text("Baixar Dados dos ativos"),
                      subtitle: const Text("Clique para baixar dados "),
                      onTap: () async {
                        await fetchAndStoreArtigos();
                      },
                    ),
                  ),
                  SizedBox(height: 10,),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.sync, color: Colors.green),
                      title: const Text("Baixar Dados das salas"),
                      subtitle: const Text("Clique para baixar dados"),
                      onTap: () async {
                        await fetchAndStoreSalas();
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
