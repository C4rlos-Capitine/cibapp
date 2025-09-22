import 'package:cibapp/inicio.dart';
import 'package:cibapp/principal.dart';
import 'package:cibapp/views/artigos/listar.dart';
import 'package:cibapp/views/artigos/registar.dart';
import 'package:cibapp/views/salas/listar.dart';
import 'package:cibapp/views/salas/registar.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

void main() {
  runApp(    MaterialApp(
    debugShowCheckedModeBanner: false,
    color: Colors.white,
    theme: ThemeData(
      primaryColor: Colors.blue[900],
    ),
    initialRoute: '/inicio',
    routes: {
      '/inicio': (context) => Inicio(),
      '/principal': (context) => Principal(),
      '/registar_sala': (context) => RegistarSala(),
      '/get_salas': (context) => ListarSalas(),
      '/registar_artigo': (context)=>RegistarArtigo(),
      '/listar_artigo': (context)=>ListarArtigos()
      /*'/inicio': (context) => Inicio(),
      '/alterar_senha': (context) => alterar_senha(codcandi: 0,)*/
    },
  ),);
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? result;

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
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
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
                setState(() {
                  result = res;
                });
              },
              child: const Text("Ler"),
            ),
            Card(
              child: ListTile(
                title: const Text("Ler Código de barra"),
                onTap: () async {
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
                  setState(() {
                    result = res;
                  });
                },
              ),
            ),
            if (result != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Scanned result: $result'),
              ),
          ],
        ),
      ),

    );
  }
}
