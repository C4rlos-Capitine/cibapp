
import 'package:cibapp/views/artigos/salas_sem_etiqueta.dart';
import 'package:flutter/material.dart';

import '../classes/Sala.dart';
import '../sincronizacao/artigos.dart';
import '../sincronizacao/em_lote.dart';
import '../sincronizacao/inventario.dart';
import '../sincronizacao/salas.dart';


class sync_screen extends StatefulWidget {
  const sync_screen({super.key});

  @override
  State<sync_screen> createState() => _sync_screenState();
}

class _sync_screenState extends State<sync_screen> {
  bool _isProcessando = false;

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

                  SizedBox(height: 10,),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.sync, color: Colors.green),
                      title: const Text("Enviar todos dados para o servidor"),
                      subtitle: const Text("Clique para sincronizar"),
                      onTap: _isProcessando
                          ? null
                          : () async {
                        setState(() {
                          _isProcessando = true;
                        });

                        bool response = await EnviarEmLote();

                        setState(() {
                          _isProcessando = false;
                        });

                        if (response == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Dados sincronizados com sucesso',
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                              backgroundColor: const Color.fromARGB(255, 55, 189, 26),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ocorreu um erro ao sincronizar',
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                              backgroundColor: const Color.fromARGB(255, 235, 65, 3),
                            ),
                          );
                        }
                      },

                    ),
                  ),
                  SizedBox(height: 5,),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.sync, color: Colors.green),
                      title: const Text("Actualize salas sem etiquetas"),
                      subtitle: const Text("Clique para baixar salas"),
                      onTap: () async {
                        List<Sala> salas =  await getSalasSemEtiqueta();
                        //bool response =  await fetchAndStoreSalas();
                        if(salas.isNotEmpty){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Dados cargados',
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                              backgroundColor:
                              Color.fromARGB(255, 55, 189, 26),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SalasSemEtiqueta(salas: salas)),
                          );
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Occoreu um erro ao baixar',
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


                ],
              ),
            ),


          ),
          if (_isProcessando)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'A sincronizar dados...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
