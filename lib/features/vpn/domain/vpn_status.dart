enum VpnConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnStatus {
  final VpnConnectionState state;
  final String? ip;
  final String? country;

  const VpnStatus({
    required this.state,
    this.ip,
    this.country,
  });

  static const disconnected = VpnStatus(state: VpnConnectionState.disconnected);
  static const connecting = VpnStatus(state: VpnConnectionState.connecting);
  static const connected = VpnStatus(state: VpnConnectionState.connected);
  static const disconnecting = VpnStatus(state: VpnConnectionState.disconnecting);
  static const error = VpnStatus(state: VpnConnectionState.error);

  VpnStatus copyWith({
    VpnConnectionState? state,
    String? ip,
    String? country,
  }) {
    return VpnStatus(
      state: state ?? this.state,
      ip: ip ?? this.ip,
      country: country ?? this.country,
    );
  }
}
