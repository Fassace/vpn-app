import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/vpn_config.dart';
import '../../domain/vpn_status.dart';
import '../controllers/vpn_notifier.dart';

class VpnHomePage extends ConsumerWidget {
  const VpnHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(vpnProvider);
    final vpnController = ref.read(vpnProvider.notifier);

    // config placeholder
    const config = VpnConfig(
      serverAddress: '1.2.3.4',
      serverPort: 51820,
      privateKey: 'sCAf+hMrydPHzk+GvJI2F8MwcvDI96JKbr54LmJggng=',
      publicKey: 'X1RtN7VN9wzEhkns1QYNSxFATggdiZanLz3Xr7/KkRQ=',
    );

    String statusText;
    Color statusColor;

    switch (status) {
      case VpnStatus.disconnected:
        statusText = "Disconnected";
        statusColor = Colors.red;
        break;
      case VpnStatus.connecting:
        statusText = "Connecting...";
        statusColor = Colors.orange;
        break;
      case VpnStatus.connected:
        statusText = "Connected";
        statusColor = Colors.green;
        break;
      case VpnStatus.disconnecting:
        statusText = "Disconnecting...";
        statusColor = Colors.orange;
        break;
      case VpnStatus.error:
        statusText = "Error!";
        statusColor = Colors.grey;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('VPN Client'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big circular button
            GestureDetector(
              onTap: () => vpnController.toggleVpn(config),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == VpnStatus.connected
                      ? Colors.green
                      : Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: status == VpnStatus.connecting ||
                          status == VpnStatus.disconnecting
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : Icon(
                          Icons.power_settings_new,
                          size: 80,
                          color: status == VpnStatus.connected
                              ? Colors.white
                              : Colors.green,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Status text
            Text(
              statusText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
