class VpnConfig {
  final String serverAddress;
  final int serverPort;
  final String privateKey;    // client private key (sensitive)
  final String publicKey;     // server/public peer key (public)
  final String allowedIps;    // e.g. '0.0.0.0/0'

  const VpnConfig({
    required this.serverAddress,
    required this.serverPort,
    required this.privateKey,
    required this.publicKey,
    this.allowedIps = '0.0.0.0/0',
  });
}
