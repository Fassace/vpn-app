import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/vpn_config.dart';
import '../../domain/vpn_status.dart';
import '../../platform/vpn_channel.dart';

class VpnNotifier extends StateNotifier<VpnStatus> {
  VpnNotifier() : super(VpnStatus.disconnected);

  Future<void> connect(VpnConfig cfg) async {
    state = VpnStatus.connecting;
    try {
      await VpnPlatform.start(cfg);
      state = await VpnPlatform.getStatus();
    } catch (_) {
      state = VpnStatus.error;
    }
  }

}

final vpnProvider = StateNotifierProvider<VpnNotifier, VpnStatus>((ref) => VpnNotifier());
