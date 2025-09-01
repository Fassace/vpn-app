import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/vpn_status.dart';
import '../../data/vpn_config.dart';

class VpnNotifier extends StateNotifier<VpnStatus> {
  VpnNotifier() : super(VpnStatus.disconnected);

  Future<void> connect(VpnConfig config) async {
    // ignore: avoid_print
    print("[VPN] Attempting to connect to: ${config.serverAddress}:${config.serverPort}");
    state = VpnStatus.connecting;

    await Future.delayed(const Duration(seconds: 2)); // simulate work
    state = VpnStatus.connected;

    // ignore: avoid_print
    print("[VPN] Connected to: ${config.serverAddress}:${config.serverPort}");
  }

  Future<void> disconnect() async {
    // ignore: avoid_print
    print("[VPN] Disconnecting...");
    state = VpnStatus.disconnecting;

    await Future.delayed(const Duration(seconds: 2)); // simulate work
    state = VpnStatus.disconnected;

    // ignore: avoid_print
    print("[VPN] Disconnected successfully.");
  }

  void toggleVpn(VpnConfig config) {
    if (state == VpnStatus.disconnected) {
      connect(config);
    } else if (state == VpnStatus.connected) {
      disconnect();
    } else {
      // ignore: avoid_print
      print("[VPN] Action ignored. Current state: $state");
    }
  }
}

final vpnProvider = StateNotifierProvider<VpnNotifier, VpnStatus>(
  (ref) => VpnNotifier(),
);
