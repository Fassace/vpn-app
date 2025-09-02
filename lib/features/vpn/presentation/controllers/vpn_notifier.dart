import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../domain/vpn_status.dart';
import '../../data/vpn_config.dart';

final logger = Logger();

class VpnNotifier extends StateNotifier<VpnStatus> {
  VpnNotifier() : super(VpnStatus.disconnected);

  Future<void> connect(VpnConfig config) async {
    logger.i("Attempting to connect to: ${config.serverAddress}:${config.serverPort}");
    state = VpnStatus.connecting;

    await Future.delayed(const Duration(seconds: 2)); // simulate work
    state = VpnStatus.connected;

    logger.i("Connected to: ${config.serverAddress}:${config.serverPort}");

    // Fetch IP + country info
    try {
      final response = await http.get(Uri.parse("http://ip-api.com/json"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ip = data['query'];
        final country = data['country'];
        state = state.copyWith(ip: ip, country: country);
        logger.i("IP: $ip, Country: $country");
      }
    } catch (e) {
      logger.e("Failed to fetch IP info", error: e);
    }
  }

  Future<void> disconnect() async {
    logger.i("Disconnecting...");
    state = VpnStatus.disconnecting;

    await Future.delayed(const Duration(seconds: 2)); // simulate work
    state = VpnStatus.disconnected;

    logger.i("Disconnected successfully.");
  }

  void toggleVpn(VpnConfig config) {
    if (state.state == VpnConnectionState.disconnected) {
      connect(config);
    } else if (state.state == VpnConnectionState.connected) {
      disconnect();
    } else {
      logger.w("Action ignored. Current state: ${state.state}");
    }
  }
}

final vpnProvider = StateNotifierProvider<VpnNotifier, VpnStatus>(
  (ref) => VpnNotifier(),
);
