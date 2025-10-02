import 'package:flutter/material.dart';
import '../../classes/Inventario.dart';
import 'InventarioDetalhePage.dart';

class InventarioListPage extends StatefulWidget {
  const InventarioListPage({Key? key}) : super(key: key);

  @override
  State<InventarioListPage> createState() => _InventarioListPageState();
}

class _InventarioListPageState extends State<InventarioListPage> {
  List<Inventario> inventarios = [];

  @override
  void initState() {
    super.initState();
    carregarInventarios();
  }

  Future<void> carregarInventarios() async {
    final lista = await Inventario.getAll();
    setState(() {
      inventarios = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventários'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Stack(
        children: [
          /// 🔹 Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'assets/imagens/f-login__background.png', // mesma imagem usada nas outras telas
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Camada escura translúcida
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          /// 🔹 Conteúdo principal
          RefreshIndicator(
            onRefresh: carregarInventarios,
            child: inventarios.isEmpty
                ? const Center(
              child: Text(
                'Nenhum inventário encontrado.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: inventarios.length,
              itemBuilder: (context, i) {
                final inv = inventarios[i];
                return Card(
                  color: Colors.white.withOpacity(0.85),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.inventory, color: Colors.blue),
                    title: Text(
                      inv.nome_inventario,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Iniciado em: ${inv.data_inicio.toLocal().toString().split(".").first}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              InventarioDetalhePage(inventario: inv),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
