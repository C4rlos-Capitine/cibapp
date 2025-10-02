import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../classes/Artigo.dart';
import '../../classes/Sala.dart';

class RegistarArtigo extends StatefulWidget {
  const RegistarArtigo({super.key});

  @override
  State<RegistarArtigo> createState() => _RegistarArtigoState();
}

class _RegistarArtigoState extends State<RegistarArtigo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numArtigoController = TextEditingController();
  final TextEditingController _nomeArtigoController = TextEditingController();
  final TextEditingController _codigoBarraController = TextEditingController();

  int? _salaSelecionada;
  List<Sala> _salas = [];

  @override
  void initState() {
    super.initState();
    _carregarSalas();
  }

  /// Carregar salas do SQLite
  Future<void> _carregarSalas() async {
    await Sala.openDb();
    List<Sala> lista = await Sala.getAllSalas();
    setState(() {
      _salas = lista;
    });
  }

  /// Scanner de código de barras
  Future<void> _scanBarcode() async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (res is String && res != "-1") {
      setState(() {
        _codigoBarraController.text = res;
        _numArtigoController.text = res;
      });
    }
  }

  /// Salvar artigo no DB
  Future<void> _salvarArtigo() async {
    if (_formKey.currentState!.validate()) {
      Artigo artigo = Artigo(
        id_sala: _salaSelecionada ?? 0,
        codigo_barra: _codigoBarraController.text.trim(),
        num_artigo: _numArtigoController.text.trim(),
        nome_artigo: _nomeArtigoController.text.trim(),
        data_registo: DateTime.now(),
        data_update: DateTime.now(),
      );

      await Artigo.openDb();
      var id = await Artigo.insert(artigo);

      if (id != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Artigo registado com sucesso!")),
        );
        _numArtigoController.clear();
        _nomeArtigoController.clear();
        _codigoBarraController.clear();
        setState(() {
          _salaSelecionada = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao registar artigo.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Fundo
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
                      "Registar Artigo",
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

                    // Número do artigo
                    TextFormField(
                      controller: _numArtigoController,
                      decoration: InputDecoration(
                        labelText: "Número do Artigo",
                        prefixIcon: const Icon(Icons.confirmation_number),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                      v == null || v.isEmpty ? "Informe o número do artigo" : null,
                    ),
                    const SizedBox(height: 16),

                    // Nome do artigo
                    TextFormField(
                      controller: _nomeArtigoController,
                      decoration: InputDecoration(
                        labelText: "Nome do Artigo",
                        prefixIcon: const Icon(Icons.inventory),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                      v == null || v.isEmpty ? "Informe o nome do artigo" : null,
                    ),
                    const SizedBox(height: 16),

                    // Sala associada (Dropdown)
                    DropdownButtonFormField<int>(
                      value: _salaSelecionada,
                      decoration: InputDecoration(
                        labelText: "Sala",
                        prefixIcon: const Icon(Icons.meeting_room),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _salas.map((sala) {
                        return DropdownMenuItem<int>(
                          value: sala.id_sala,
                          child: Text("Sala ${sala.num_sala}"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _salaSelecionada = value;
                        });
                      },
                      validator: (v) =>
                      v == null ? "Selecione uma sala" : null,
                    ),
                    const SizedBox(height: 16),

                    // Código de barras
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
                      validator: (v) =>
                      v == null || v.isEmpty ? "Escaneie o código de barras" : null,
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
                        onPressed: _salvarArtigo,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          "Salvar Artigo",
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
