enum KeycapStyle {
  round,
  pill,
  longPill,
}

class MiniKeycapData {
  const MiniKeycapData(
    this.primary, {
    this.secondary,
    this.style = KeycapStyle.round,
    this.flex = 1,
  });

  final String primary;
  final String? secondary;
  final KeycapStyle style;
  final int flex;
}
