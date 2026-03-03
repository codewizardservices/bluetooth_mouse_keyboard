class DeviceEntity {
  final String address;
  final String name;
  final bool isPaired;
  final int? rssi;

  DeviceEntity({
    required this.address,
    required this.name,
    this.isPaired = false,
    this.rssi,
  });

  DeviceEntity copyWith({
    String? address,
    String? name,
    bool? isPaired,
    int? rssi,
  }) {
    return DeviceEntity(
      address: address ?? this.address,
      name: name ?? this.name,
      isPaired: isPaired ?? this.isPaired,
      rssi: rssi ?? this.rssi,
    );
  }
}

enum DeviceHidConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

