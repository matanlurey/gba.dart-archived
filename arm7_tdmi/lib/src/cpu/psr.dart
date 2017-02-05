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
  int _word;

  StatusRegister([this._word = 0]);

  /// Word that represents this register.
  int get word => _word;

  /// Whether fast-interrupts is disabled.
  bool get isFastInterruptsDisabled => isSet(getBit(6, _word));

  /// Enable fast-interrupts.
  void enableFastInterrupts() {
    _word = unsetBit(6, _word);
  }

  /// Disable fast-interrupts.
  void disableFastInterrupts() {
    _word = setBit(6, _word);
  }

  /// Whether interrupts is disabled.
  bool get isInterruptsDisabled => isSet(getBit(7, _word));

  /// Enable interrupts.
  void enableInterrupts() {
    _word = unsetBit(7, _word);
  }

  /// Disable interrupts.
  void disableInterrupts() {
    _word = setBit(7, _word);
  }

  /// Whether to overflow.
  bool get isOverflow => isSet(getBit(28, _word));

  /// Enable overflow.
  void enableOverflow() {
    _word = setBit(28, _word);
  }

  /// Disable overflow.
  void disableOverflow() {
    _word = unsetBit(28, _word);
  }

  bool get isBorrow => !isCarry;

  /// Whether to carry.
  bool get isCarry => isSet(getBit(29, _word));

  /// Enable carry (disabling borrow).
  void enableCarry() {
    _word = setBit(29, _word);
  }

  /// Disable carry (enabling borrow).
  void disableCarry() {
    _word = unsetBit(29, _word);
  }

  /// Whether to use zero; otherwise is non-zero.
  bool get isZero => isSet(getBit(30, _word));

  /// Set zero.
  void setZero() {
    _word = setBit(30, _word);
  }

  /// Set non-zero.
  void setNonZero() {
    _word = unsetBit(30, _word);
  }

  /// Whether signed; otherwise unsigned.
  bool get isSigned => isSet(getBit(31, _word));

  /// Whether unsigned.
  bool get isUnsigned => isUnset(getBit(31, _word));

  /// Set signed.
  void setSigned() {
    _word = setBit(31, _word);
  }

  /// Set unsigned.
  void setUnsigned() {
    _word = unsetBit(31, _word);
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
