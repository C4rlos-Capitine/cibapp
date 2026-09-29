import 'package:cibapp/classes/Artigo.dart';
import 'package:cibapp/sincronizacao/salas.dart';
import 'package:cibapp/views/artigos/artigo_por_sala.dart';
//import 'package:cibapp/views/artigos/artigos_por_sala.dart';
import 'package:cibapp/views/artigos/listar.dart';
import 'package:cibapp/views/inventario/InventarioListPage.dart';
import 'package:cibapp/views/inventario/ListInventario.dart';
import 'package:cibapp/views/inventario/inventario.dart';
import 'package:cibapp/views/inventario/inventario_realtime.dart';
import 'package:cibapp/views/inventario/inventario_teste.dart';
import 'package:cibapp/views/salas/listar.dart';
import 'package:cibapp/views/verificacao/lista.dart';
import 'package:cibapp/views/sync_screen.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import 'classes/ArtigoInventario.dart';
import 'classes/Inventario.dart';
import 'classes/Sala.dart';

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
  void initState() {
    // TODO: implement initState
    super.initState();
    init_tables();
  }

  Future<void> init_tables() async {
    Sala.openDb();
    Artigo.openDb();
    Inventario.openDb();
    InventarioArtigo.openDb();
  }

/*
  Future<void> _lerSalaEIrParaInventario(BuildContext context) async {
    // 🔹 Ler código de barras
    final result = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Leitura da Sala',
        centerTitle: true,
        enableBackButton: true,
      ),
      isShowFlashIcon: true,
      delayMillis: 2000,
      cameraFace: CameraFace.back,
    );

    if (result == null || result.isEmpty || result == "-1") return;

    try {
      // 🔹 Buscar sala no servidor
      final Sala? sala = await fetchSingleFromServer(result);

      if (sala == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sala não encontrada no servidor: $result')),
        );
        return;
      }

      // 🔹 (Opcional) guardar localmente
      await Sala.insertOrUpdate(sala);

      // 🔹 Navegar para inventário em tempo real
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => realTimeInventory(sala: sala),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar sala: $e')),
      );
    }
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        /*leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
        ),*/
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
                image: AssetImage("assets/imagens/HCB_app-background.png"),
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
                      leading:
                          const Icon(Icons.meeting_room, color: Colors.blue),
                      title: const Text("Salas"),
                      subtitle:
                          const Text("Clique para ver os ativos de cada sala"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ListarSalas()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  /* Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.green),
                      title: const Text("Ativos"),
                      subtitle: const Text("Clique para ver os ativos"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ListarArtigos()),
                        );
                      },
                    ),
                  ),
                 Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.green),
                      title: const Text("Ler Sala"),
                      subtitle: const Text("Clique para ver ativos de uma sala"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ArtigosPorSala()),
                        );
                      },
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.sync, color: Colors.green),
                      title: const Text("Sincronização de Dados"),
                      subtitle: const Text("Clique para mais sobre sync"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const sync_screen()),
                        );
                      },
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.sync, color: Colors.green),
                      title: const Text("Inventário em tempo real"),
                      subtitle: const Text("Ler código da sala"),
                      onTap: () async {
                       // await _lerSalaEIrParaInventario(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => realTimeInventory(),
                          ),
                        );
                      },
                    ),
                  ),
           Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.green),
                      title: const Text("Registo de Inventário"),
                      subtitle: const Text("Clique para registar"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InventarioPage()),
                        );
                      },
                    ),
                  ),
                 Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.green),
                      title: const Text("Registo de Inventário(para teste)"),
                      subtitle: const Text("Clique para registar"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const inventario_teste()),
                        );
                      },
                    ),
                  ),*/
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.green),
                      title: const Text("Inventário"),
                      subtitle: const Text("Clique para mais.."),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Listinventario()),
                          //MaterialPageRoute(builder: (context) => const InventarioListPage()),
                        );
                      },
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: const Icon(Icons.inventory, color: Colors.green),
                      title: const Text("Verificações"),
                      subtitle: const Text("Clique para mais.."),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ListarVerificacao()),
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
