import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../classes/Sala.dart';

class SalasSemEtiqueta extends StatefulWidget {
  final List<Sala> salas;
  const SalasSemEtiqueta({super.key, required this.salas});

  @override
  State<SalasSemEtiqueta> createState() => _SalasSemEtiquetaState();
}

class _SalasSemEtiquetaState extends State<SalasSemEtiqueta> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salas sem etiqueta"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Stack(
        children: [
          /// 🔹 Imagem de fundo
          Positioned.fill(
            child: Image.asset(
              'assets/imagens/f-login__background.png',
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Camada escurecida
          Container(color: Colors.black.withOpacity(0.4)),

          /// 🔹 Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(12),
            child: widget.salas.isEmpty
                ? const Center(
              child: Text(
                'Nenhuma sala sem etiqueta encontrada.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: widget.salas.length,
              itemBuilder: (context, index) {
                final sala = widget.salas[index];

                return Card(
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.meeting_room, color: Colors.blue),
                    title: Text(
                      sala.num_sala,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Código: ${sala.codigo_barra.isEmpty ? "—" : sala.codigo_barra}'),
                        Text('Última atualização: ${sala.lastUpdated.toString().split(".").first}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.green),
                      tooltip: 'Escanear etiqueta',
                      onPressed: () async {
                        /// 🔹 Abre o scanner
                        var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SimpleBarcodeScannerPage(),
                          ),
                        );

                        if (res is String && res.isNotEmpty) {
                          setState(() {
                            sala.codigo_barra = res;
                            sala.lastUpdated = DateTime.now();
                            sala.isSynced = 0;
                          });

                          /// 🔹 Salva localmente no SQLite
                          await Sala.insertOrUpdate(sala);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Etiqueta atribuída e salva: $res'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
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
