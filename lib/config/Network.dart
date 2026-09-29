// config.dart
library config;

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

var address = "157.173.99.199";
var port = 8003;
var address_port = "${address}:$port";
//const address_port = "192.168.10.191:5019";
//const address_port = "192.168.10.118:5021";

Future<NetworkCheckResponse> isConnected() async {
  try {
    //final connectivityResult = await Connectivity().checkConnectivity();
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    print('Connectivity Result: $connectivityResult'); // Debug print

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return NetworkCheckResponse(state: false, mesg: "Não conectado à rede");
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return NetworkCheckResponse(
        state: true,
        mesg: "Conectado à rede móvel",
      );
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return NetworkCheckResponse(
        state: true,
        mesg: "Conectado à rede Wi-Fi",
      );
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return NetworkCheckResponse(
        state: true,
        mesg: "Conectado à rede Ethernet",
      );
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      return NetworkCheckResponse(
        state: true,
        mesg: "Conectado através de VPN",
      );
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      return NetworkCheckResponse(
        state: true,
        mesg: "Conectado através de Bluetooth",
      );
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      return NetworkCheckResponse(
        state: true,
        mesg: "Conectado a uma rede desconhecida",
      );
    } else {
      return NetworkCheckResponse(
        state: false,
        mesg: "Estado de rede desconhecido",
      );
    }
  } catch (e) {
    // Handle possible exceptions (e.g., no permission to access connectivity)
    return NetworkCheckResponse(
      state: false,
      mesg: "Erro ao verificar a conectividade: ${e.toString()}",
    );
  }
}

Future<bool> checkServer(String host, int port) async {
  try {
    final socket =
        await Socket.connect(host, port, timeout: Duration(seconds: 5));
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

class NetworkCheckResponse {
  late bool state;
  late String mesg;
  NetworkCheckResponse({required this.state, required this.mesg});
}
