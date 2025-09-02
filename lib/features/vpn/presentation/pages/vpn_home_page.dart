import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/vpn_config.dart';
import '../../domain/vpn_status.dart';
import '../controllers/vpn_notifier.dart';

class VpnHomePage extends ConsumerStatefulWidget {
  const VpnHomePage({super.key});

  @override
  ConsumerState<VpnHomePage> createState() => _VpnHomePageState();
}

class _VpnHomePageState extends ConsumerState<VpnHomePage> {
  String selectedCountry = "Nigeria";

  final Map<String, VpnConfig> servers = {
    "Nigeria": VpnConfig(
      serverAddress: '1.2.3.4', // Nigeria WireGuard server IP
      serverPort: 51820,
      privateKey: 'sCAf+hMrydPHzk+GvJI2F8MwcvDI96JKbr54LmJggng=',
      publicKey: 'X1RtN7VN9wzEhkns1QYNSxFATggdiZanLz3Xr7/KkRQ=',
    ),
    "USA": VpnConfig(
      serverAddress: '5.6.7.8',
      serverPort: 51820,
      privateKey: 'your_us_private_key',
      publicKey: 'your_us_public_key',
    ),
    "Germany": VpnConfig(
      serverAddress: '9.10.11.12',
      serverPort: 51820,
      privateKey: 'your_germany_private_key',
      publicKey: 'your_germany_public_key',
    ),
    "Canada": VpnConfig(
      serverAddress: '13.14.15.16',
      serverPort: 51820,
      privateKey: 'your_canada_private_key',
      publicKey: 'your_canada_public_key',
    ),
    "Russia": VpnConfig(
      serverAddress: '17.18.19.20',
      serverPort: 51820,
      privateKey: 'your_russia_private_key',
      publicKey: 'your_russia_public_key',
    ),
    "Asia": VpnConfig(
      serverAddress: '21.22.23.24',
      serverPort: 51820,
      privateKey: 'your_asia_private_key',
      publicKey: 'your_asia_public_key',
    ),
  };

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Exit"),
          ),
        ],
      ),
    );
    if (shouldExit ?? false) {
      exit(0); // Close app
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(vpnProvider);
    final vpnController = ref.read(vpnProvider.notifier);
    final config = servers[selectedCountry]!;

    String statusText;
    Color statusColor;

    switch (status.state) {
      case VpnConnectionState.disconnected:
        statusText = "Disconnected";
        statusColor = Colors.red;
        break;
      case VpnConnectionState.connecting:
        statusText = "Connecting...";
        statusColor = Colors.orange;
        break;
      case VpnConnectionState.connected:
        statusText = "Connected";
        statusColor = Colors.green;
        break;
      case VpnConnectionState.disconnecting:
        statusText = "Disconnecting...";
        statusColor = Colors.orange;
        break;
      case VpnConnectionState.error:
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Exit App"),
              onTap: () => _confirmExit(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Country selector in rounded box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: DropdownButton<String>(
                value: selectedCountry,
                underline: const SizedBox(),
                items: servers.keys.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCountry = value);
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // Big circular button
            GestureDetector(
              onTap: () => vpnController.toggleVpn(config),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status.state == VpnConnectionState.connected
                      ? Colors.green
                      : Colors.grey[300],
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: status.state == VpnConnectionState.connecting ||
                          status.state == VpnConnectionState.disconnecting
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : Icon(
                          Icons.power_settings_new,
                          size: 80,
                          color: status.state == VpnConnectionState.connected
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

            // Show IP + Country if connected
            if (status.state == VpnConnectionState.connected) ...[
              const SizedBox(height: 10),
              Text("IP: ${status.ip ?? '-'}"),
              Text("Country: ${status.country ?? '-'}"),
            ],
          ],
        ),
      ),
    );
  }
}
