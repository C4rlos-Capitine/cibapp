import 'package:flutter/material.dart';
import '../../classes/Inventario.dart';
import '../../sincronizacao/inventario.dart';
import 'inventario_realtime.dart';
import 'dart:convert';
import '../../config/Network.dart';

class Listinventario extends StatefulWidget {
  const Listinventario({super.key});

  @override
  State<Listinventario> createState() => _ListinventarioState();
}

class _ListinventarioState extends State<Listinventario> {
  late Future<List<Inventario>?> inventarioFuture;
  @override
  void initState() {
    super.initState();

    inventarioFuture = _loadInventarios();
  }

  Future<void> _initializeData() async {
    // Check network status and wait for the result
    NetworkCheckResponse networkStatus = await isConnected();
    bool serverStatus = await checkServer(address, port);
    if (!networkStatus.state) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(networkStatus.mesg)),
      );
    } else if (!serverStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Serviço indisponível")),
      );
    } else {
      // Network and server are available, proceed with data initialization
      //await fetchAndStoreInventarioArtigos();
    }
    SnackBar snackBar = SnackBar(content: Text(networkStatus.mesg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<List<Inventario>?> _loadInventarios() async {
    return await fetchAndStoreInventarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Inventário"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Mesmo background utilizado na tela de Login
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/imagens/HCB_app-background.png",
            ),
            fit: BoxFit.cover,
          ),
        ),

        child: FutureBuilder<List<Inventario>?>(
          future: inventarioFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erro: ${snapshot.error}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhum inventário encontrado",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            final inventarios = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              itemCount: inventarios.length,
              itemBuilder: (context, index) {
                final inv = inventarios[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  // Transparência para permitir visualizar o background
                  color: Colors.white.withOpacity(0.92),

                  elevation: 4,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: ListTile(
                    leading: const Icon(
                      Icons.inventory,
                      color: Colors.blue,
                      size: 32,
                    ),
                    title: Text(
                      inv.nome_inventario,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "ID: ${inv.id_inventario}",
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => realTimeInventory(
                            id_inventario_unique: inv.id_inventario_unique,
                            nome_inventario: inv.nome_inventario,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
