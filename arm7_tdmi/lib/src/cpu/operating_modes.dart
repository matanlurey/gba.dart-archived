/// A representation of the seven ARM Cpu operating modes.
class OperatingMode {
  final String identifier;

  /// The usual Cpu operating mode.
  ///
  /// Used for executing most application programs.
  static const OperatingMode user = const OperatingMode._('usr');

  /// Supports a data transfer or channel process.
  static const OperatingMode fastInterrupt = const OperatingMode._('fiq');

  /// Used for general purpose interrupt handling.
  static const OperatingMode interrupt = const OperatingMode._('irq');

  /// A protected mode for the operating system.
  static const OperatingMode supervisor = const OperatingMode._('svc');

  /// Entered after a data or instruction prefetch abort.
  static const OperatingMode abort = const OperatingMode._('abt');

  /// A privileged user mode for the operating system.
  static const OperatingMode system = const OperatingMode._('sys');

  /// Entered when an undefined instruction is executed.
  static const OperatingMode undefined = const OperatingMode._('und');

  const OperatingMode._(this.identifier);

  @override
  String toString() => identifier;

  /// Whether this is a privileged [OperatingMode].
  ///
  /// All modes other than [OperatingMode.user] are privileged.
  bool get isPrivileged => this == user;

  /// Whether this mode can read or write the saved program status registers.
  ///
  /// Only exception modes have read/write access. All modes are exception modes
  /// except for [user] and [system].
  bool get canAccessSpsr => this != user && this != system;
}
