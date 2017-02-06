/// A representation of the seven ARM7/TDMI operating modes.
class Arm7TdmiOperatingMode {
  /// Four (4) bits representing this operating mode.
  final int bits;

  /// String representation of the operating mode.
  final String identifier;

  /// The usual Cpu operating mode.
  ///
  /// Used for executing most application programs.
  static const usr = const Arm7TdmiOperatingMode._(0x10, 'usr');

  /// Supports a data transfer or channel process.
  static const fiq = const Arm7TdmiOperatingMode._(0x11, 'fiq');

  /// Used for general purpose interrupt handling.
  static const irq = const Arm7TdmiOperatingMode._(0x12, 'irq');

  /// A protected mode for the operating system.
  static const svc = const Arm7TdmiOperatingMode._(0x13, 'svc');

  /// Entered after a data or instruction prefetch abort.
  static const abt = const Arm7TdmiOperatingMode._(0x17, 'abt');

  /// A privileged user mode for the operating system.
  static const sys = const Arm7TdmiOperatingMode._(0x1F, 'sys');

  /// Entered when an undefined instruction is executed.
  static const und = const Arm7TdmiOperatingMode._(0x1B, 'und');

  /// All valid operating modes.
  static const values = const [
    usr,
    fiq,
    irq,
    svc,
    abt,
    sys,
    und,
  ];

  const Arm7TdmiOperatingMode._(this.bits, this.identifier);

  /// Whether this is a privileged [Arm7TdmiOperatingMode].
  ///
  /// All modes other than [Arm7TdmiOperatingMode.usr] are privileged.
  bool get isPrivileged => this == usr;

  /// Whether this mode can read or write the saved program status registers.
  ///
  /// Only exception modes have read/write access. All modes are exception modes
  /// except for [usr] and [sys].
  bool get canAccessSpsr => this != usr && this != sys;

  @override
  String toString() => '$identifier {${bits.toRadixString(2)}}';
}
