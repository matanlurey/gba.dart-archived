import 'package:arm7_tdmi/src/utils/bits.dart';

/// Program status register.
///
/// Maintains condition flags, interrupt disable bits, the current processor
/// mode and other status and control information.
///
/// The bit map for ARMv4 program status registers is as follows:
/// ```txt
/// |31|30|29|28|27    25|24|23     8|7|6|5|4    0|
/// |N |Z |C |V |Reserved|J |Reserved|I|F|T|M[4:0]|
/// ```
class StatusRegister {
  int _byte;

  StatusRegister([this._byte = 0]);

  /// Byte that represents this register.
  int get byte => _byte;

  /// Whether fast-interrupts is disabled.
  bool get isFastInterruptsDisabled => isSet(getBit(6, _byte));

  /// Enable fast-interrupts.
  void enableFastInterrupts() {
    _byte = unsetBit(6, _byte);
  }

  /// Disable fast-interrupts.
  void disableFastInterrupts() {
    _byte = setBit(6, _byte);
  }

  /// Whether interrupts is disabled.
  bool get isInterruptsDisabled => isSet(getBit(7, _byte));

  /// Enable interrupts.
  void enableInterrupts() {
    _byte = unsetBit(7, _byte);
  }

  /// Disable interrupts.
  void disableInterrupts() {
    _byte = setBit(7, _byte);
  }

  /// Whether to overflow.
  bool get isOverflow => isSet(getBit(28, _byte));

  /// Enable overflow.
  void enableOverflow() {
    _byte = setBit(28, _byte);
  }

  /// Disable overflow.
  void disableOverflow() {
    _byte = unsetBit(28, _byte);
  }

  bool get isBorrow => !isCarry;

  /// Whether to carry.
  bool get isCarry => isSet(getBit(29, _byte));

  /// Enable carry (disabling borrow).
  void enableCarry() {
    _byte = setBit(29, _byte);
  }

  /// Disable carry (enabling borrow).
  void disableCarry() {
    _byte = unsetBit(29, _byte);
  }

  /// Whether to use zero; otherwise is non-zero.
  bool get isZero => isSet(getBit(30, _byte));

  /// Set zero.
  void setZero() {
    _byte = setBit(30, _byte);
  }

  /// Set non-zero.
  void setNonZero() {
    _byte = unsetBit(30, _byte);
  }

  /// Whether signed; otherwise unsigned.
  bool get isSigned => isSet(getBit(31, _byte));

  /// Whether unsigned.
  bool get isUnsigned => isUnset(getBit(31, _byte));

  /// Set signed.
  void setSigned() {
    _byte = setBit(31, _byte);
  }

  /// Set unsigned.
  void setUnsigned() {
    _byte = unsetBit(31, _byte);
  }

  @override
  String toString() =>
      '$StatusRegister {' +
      {
        'F': isFastInterruptsDisabled ? 1 : 0,
        'I': isInterruptsDisabled ? 1 : 0,
        'V': isOverflow ? 1 : 0,
        'C': isCarry ? 1 : 0,
        'Z': isZero ? 1 : 0,
        'N': isSigned ? 1 : 0,
      }.toString() +
      '}';
}
