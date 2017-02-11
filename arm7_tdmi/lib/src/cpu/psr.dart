import 'dart:typed_data';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';
import 'package:func/func.dart';
import 'package:meta/meta.dart';

/// Utility functions around reading and writing flags to the CPSR/SPSR.
///
/// CPSR bits are as following:
/// ```
/// 0 - 4:    M0 - M4 - Mode bits.
/// 5:        T - State bit.
/// 6:        F - FIQ disable         (0=Enable, 1=Disable)
/// 7:        I - IRQ disable         (0=Enable, 1=Disable)
/// 8 - 26:   Reserved
/// 27:       Q - Sticky overflow     (1=Sticky overflow, ARMv5TE and up only)
/// 28:       V - Overflow flag       (0=No Overflow, 1=Overflow)
/// 29:       C - Carry flag          (0=Borrow/No carry, 1=Carry/No borrow)
/// 30:       Z - Zero flag           (0=Not zero, 1=Zero)
/// 31:       N - Sign flag           (0=Not signed, 1=Signed)
/// ```
///
/// ## Bit 31 -> 28: Condition Code Flags (N,Z,C,V)
///
/// These bits reflect results of logical or arithmetic instructions. In `ARM`
/// mode, it is often optionally whether an instruction should modify flags or
/// not, for example, it is possible to execute a SUB instruction that does NOT
/// modify the condition flags.
///
/// In `ARM` state, all instructions can be executed conditionally depending on
/// the settings of the flags, such like `MOVEQ` (Move if Z=1). While In `THUMB`
/// state, only Branch instructions (jumps) can be made conditionally.
///
/// ## Bit 27: Sticky Overflow Flag (Q) - ARMv5TE and ARMv5TExP and up only
///
/// Used by `QADD`, `QSUB`, `QDADD`, `QDSUB`, `SMLAxy`, and `SMLAWy` only. These
/// opcodes set the Q-flag in case of overflows, but leave it unchanged
/// otherwise. The Q-flag can be tested/reset by `MSR`/`MRS` opcodes only.
///
/// ## Bit 27 -> 8: Reserved Bits (except Bit 27 on ARMv5TE and up, see above)
///
/// These bits are reserved for possible future implementations. For best
/// forwards compatibility, the user should never change the state of these
/// bits, and should not expect these bits to be set to a specific value.
///
/// ## Bit 0 -> 7: Control Bits (I,F,T,M4-M0)
///
/// These bits may change when an exception occurs. In privileged modes
/// (non-user modes) they may be also changed manually.
///
/// The interrupt bits I and F are used to disable IRQ and FIQ interrupts
/// respectively (a setting of `1` means disabled).
///
/// The T Bit signalizes the current state of the CPU (0=`ARM`, 1=`THUMB`), this
/// bit should never be changed manually - instead, changing between `ARM` and
/// `THUMB` state must be done by `BX` instructions.
///
/// To determine the current operating mode, look at bits M4-M0 as such:
///
/// ````
/// 10000 = User
/// 10001 = FIQ
/// 10010 = IRQ
/// 10011 = Supervisor
/// 10111 = Abort
/// 11011 = Undefined
/// 11111 = System
/// ````
///
/// Writing any other values into the Mode bits is not allowed.
///
/// TODO: Add explanation of SPSR.
class Arm7TdmiPsr {
  static const _bitModeStart = 0;
  static const _bitModeEnd = 4;
  static const _bitState = 5;
  static const _bitSticky = 27;
  static const _bitOverflow = 28;
  static const _bitCarry = 29;
  static const _bitZero = 30;
  static const _bitSign = 31;

  // Reads from memory.
  final Func0<int> _read;

  // Writes to memory.
  final VoidFunc1<int> _write;

  /// Create a new PSR that accesses bits in memory from a view.
  const Arm7TdmiPsr({
    @required int read(),
    @required void write(int value),
  })
      : _read = read,
        _write = write;

  /// Creates a new PSR with a starting value of [bits].
  factory Arm7TdmiPsr.fromBits([int bits]) {
    bits ??= 0 | Arm7TdmiOperatingMode.usr.bits;
    return new Arm7TdmiPsr(read: () => bits, write: (v) => bits = v);
  }

  /// Creates a new PSR that reads/writes into [location] in [memory].
  factory Arm7TdmiPsr.fromView(Uint32List memory, int location) {
    return new Arm7TdmiPsr(
      read: () => memory[location],
      write: (value) => memory[location] = value,
    );
  }

  // Operating modes.

  /// Current operating mode.
  Arm7TdmiOperatingMode get operatingMode {
    final m0m4 = int32.range(_read(), _bitModeEnd, _bitModeStart);
    for (final mode in Arm7TdmiOperatingMode.values) {
      if (m0m4 == mode.bits) {
        return mode;
      }
    }
    throw new StateError(
      'Could not find an operating mode: ${m0m4.toRadixString(2)}.',
    );
  }

  set operatingMode(Arm7TdmiOperatingMode operatingMode) {
    _write(_read() | operatingMode.bits);
    assert(operatingMode != null);
  }

  // ARM v THUMB state.

  /// Whether in `ARM` state.
  bool get isArmState => !isThumbState;

  /// Whether in `THUMB` state.
  bool get isThumbState => _isSet(_bitState);

  /// Sets the state to `ARM`.
  void setStateToArm() {
    _unsetBit(_bitState);
  }

  /// Sets the state to `THUMB`.
  void setStateToThumb() {
    _setBit(_bitState);
  }

  // Sticky Overflow (Q).

  /// Sticky Overflow (Q) flag.
  bool get q => _isSet(_bitSticky);
  set q(bool stickyOverflow) {
    _toggleBit(_bitSticky, stickyOverflow);
  }

  /// Overflow (V) flag.
  bool get v => _isSet(_bitOverflow);
  set v(bool overflow) {
    _toggleBit(_bitOverflow, overflow);
  }

  /// Carry (C) flag.
  bool get c => _isSet(_bitCarry);
  set c(bool carry) {
    _toggleBit(_bitCarry, carry);
  }

  /// Zero (Z) flag.
  bool get z => _isSet(_bitZero);
  set z(bool zero) {
    _toggleBit(_bitZero, zero);
  }

  /// Sign (N) flag.
  bool get n => _isSet(_bitSign);
  set n(bool sign) {
    _toggleBit(_bitSign, sign);
  }

  // Returns whether a bit is "set" at index (i.e. is `1` not `0`).
  bool _isSet(int index) => _readBit(index) == 1;

  // Returns a bit by index.
  int _readBit(int index) => uint32.get(_read(), index);

  // Toggles the value of a bit.
  void _toggleBit(int index, bool value) {
    value ? _setBit(index) : _unsetBit(index);
  }

  // Sets a bit by index.
  void _setBit(int index) {
    _write(uint32.set(_read(), index));
  }

  // Un-sets a bit by index.
  void _unsetBit(int index) {
    _write(uint32.clear(_read(), index));
  }

  /// Returns the bits representing this PSR.
  int toValue() => _read();
}
