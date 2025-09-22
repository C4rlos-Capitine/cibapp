import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../classes/Sala.dart';
 // importa a classe Sala

class RegistarSala extends StatefulWidget {
  const RegistarSala({super.key});

  @override
  State<RegistarSala> createState() => _RegistarSalaState();
}

class _RegistarSalaState extends State<RegistarSala> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numSalaController = TextEditingController();
  final TextEditingController _codigoBarraController = TextEditingController();

  /// Função para abrir scanner
  Future<void> _scanBarcode() async {
        String? res = await SimpleBarcodeScanner.scanBarcode(
          context,
          barcodeAppBar: const BarcodeAppBar(
            appBarTitle: 'Test',
            centerTitle: false,
            enableBackButton: true,
            backButtonIcon: Icon(Icons.arrow_back_ios),
          ),
          isShowFlashIcon: true,
          delayMillis: 2000,
          cameraFace: CameraFace.back,
        );

    if (res is String && res != "-1") {
      setState(() {
        _codigoBarraController.text = res;
      });
    }
  }

  /// Função para salvar no DB
  Future<void> _salvarSala() async {
    if (_formKey.currentState!.validate()) {
      Sala sala = Sala(
        codigo_barra: _codigoBarraController.text.trim(),
        num_sala: _numSalaController.text.trim(),
      );

      await Sala.openDb();
      var id = await Sala.insert(sala);

      if (id != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sala registada com sucesso!")),
        );
        _numSalaController.clear();
        _codigoBarraController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao registar sala.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Registar Sala",
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
                    const SizedBox(height: 24),

                    // Campo número da sala
                    TextFormField(
                      controller: _numSalaController,
                      decoration: InputDecoration(
                        labelText: "Número da Sala",
                        prefixIcon: const Icon(Icons.meeting_room),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Informe o número da sala" : null,
                    ),
                    const SizedBox(height: 16),

                    // Campo código de barra
                    TextFormField(
                      controller: _codigoBarraController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Código de Barras",
                        prefixIcon: const Icon(Icons.qr_code),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _scanBarcode,
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Escaneie o código de barras" : null,
                    ),
                    const SizedBox(height: 24),

                    // Botão salvar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _salvarSala,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          "Salvar Sala",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
