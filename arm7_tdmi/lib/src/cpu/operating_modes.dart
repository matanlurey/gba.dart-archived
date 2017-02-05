class OperatingMode {
  final String identifier;

  static const OperatingMode user = const OperatingMode._('usr');
  static const OperatingMode fastInterrupt = const OperatingMode._('fiq');
  static const OperatingMode interrupt = const OperatingMode._('irq');
  static const OperatingMode supervisor = const OperatingMode._('svc');
  static const OperatingMode abort = const OperatingMode._('abt');
  static const OperatingMode system = const OperatingMode._('sys');
  static const OperatingMode undefined = const OperatingMode._('und');

  const OperatingMode._(this.identifier);

  @override
  String toString() => identifier;
}
