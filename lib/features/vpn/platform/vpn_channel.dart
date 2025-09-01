import 'package:flutter/services.dart';
import '../domain/vpn_status.dart';
import '../data/vpn_config.dart';

class VpnPlatform {
  static const _channel = MethodChannel('app.vpn/channel');

  static Future<VpnStatus> getStatus() async {
    final s = await _channel.invokeMethod<String>('status');
    switch (s) {
      case 'connected':
        return VpnStatus.connected;
      case 'connecting':
        return VpnStatus.connecting;
      case 'error':
        return VpnStatus.error;
      default:
        return VpnStatus.disconnected;
    }
  }

  static Future<void> start(VpnConfig cfg) async {
    await _channel.invokeMethod('start', {
      'serverAddress': cfg.serverAddress,
      'serverPort': cfg.serverPort,
      'privateKey': cfg.privateKey,
      'publicKey': cfg.publicKey,
      'allowedIps': cfg.allowedIps,
    });
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }
}
