import 'package:arm7_tdmi/src/utils/bits.dart';

/// Program status registers.
///
/// Maintains condition flags, interrupt disable bits, the current processor
/// mode and other status and control information.
///
/// The bit map for ARMv4 program status registers is as follows:
///
/// |31|30|29|28|27    25|24|23     8|7|6|5|4    0|
/// |N |Z |C |V |Reserved|J |Reserved|I|F|T|M[4:0]|
class ProgramStatusRegisters {
  int _bits;

  ProgramStatusRegisters.copyFrom(ProgramStatusRegisters other)
      : _bits = other._bits;

  ProgramStatusRegisters([this._bits = 0]);

  bool get areFIQInterruptsEnabled => isUnset(getBit(6, _bits));

  bool get areIRQInterruptsEnabled => isUnset(getBit(7, _bits));

  int get negativeFlag => getBit(31, _bits);
  set negativeFlag(int value) {
    _bits = setBit(31, _bits);
  }

  int get zeroFlag => getBit(30, _bits);
  set zeroFlag(int value) {
    _bits = setBit(30, _bits);
  }

  int get carryFlag => getBit(29, _bits);
  set carryFlag(int value) {
    _bits = setBit(29, _bits);
  }

  int get overflowFlag => getBit(28, _bits);
  set overflowFlag(int value) {
    _bits = setBit(28, _bits);
  }

  void enableIRQInterrupts() {
    _bits = unsetBit(7, _bits);
  }

  void disableIRQInterrupts() {
    _bits = setBit(7, _bits);
  }

  void enableFIQInterrupts() {
    _bits = unsetBit(6, _bits);
  }

  void disableFIQInterrupts() {
    _bits = setBit(6, _bits);
  }

  /// Returns a copy of the register's internal state.
  int dump() => _bits;
}
