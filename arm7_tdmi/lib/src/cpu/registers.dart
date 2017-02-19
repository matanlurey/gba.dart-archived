import 'dart:typed_data';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:meta/meta.dart';

/// ARM7TDMI register set which is available in each mode.
///
/// There's a total of 37 registers (32bit), 31 general registers (`Rxx`) and
/// 6 status registers (`xPSR`). Note that only some resisters are "banked",
/// for example each mode has it's own `R14` register: called `R14`, `R14_fiq`,
/// `R14_svc1, etc. for each mode respectively
///
/// However, other registers are not banked, for example, each mode is using the
/// same `R0` register, so writing to `R0` will always affect the content of
/// `R0` in other modes also.
///
/// ```txt
/// System/User     FIQ         Supervisor     Abort     IRQ      Undefined
/// -----------------------------------------------------------------------
/// R0              R0          R0             R0        R0       R0
/// R1              R1          R1             R1        R1       R1
/// R2              R2          R2             R2        R2       R2
/// R3              R3          R3             R3        R3       R3
/// R4              R4          R4             R4        R4       R4
/// R5              R5          R5             R5        R5       R5
/// R6              R6          R6             R6        R6       R6
/// R7              R7          R7             R7        R7       R7
/// -----------------------------------------------------------------------
/// R8              R8_fiq      R8             R8        R8       R8
/// R9              R9_fiq      R9             R9        R9       R9
/// R10             R10_fiq     R10            R10       R10      R10
/// R11             R11_fiq     R11            R11       R11      R11
/// R12             R12_fiq     R12            R12       R12      R12
/// R13 (SP)        R13_fiq     R13_svc        R13_abt   R13_irq  R13_und
/// R14 (LR)        R14_fiq     R14_svc        R14_abt   R14_irq  R14_und
/// R15 (PC)        R15         R15            R15       R15      R15
/// -----------------------------------------------------------------------
/// CPSR            CPSR        CPSR           CPSR      CPSR     CPSR
/// --              SPSR_fiq    SPSR_svc       SPSR_abt  SPSR_irq SPSR_und
/// -----------------------------------------------------------------------
/// ```
class Arm7TdmiRegisters {
  static const _fiqViewOffset = 17;
  static const _fiqViewLength = 7;
  static const _svcViewOffset = _fiqViewOffset + _fiqViewLength;
  static const _svcViewLength = 3;
  static const _abtViewOffset = _svcViewOffset + _svcViewLength;
  static const _abtViewLength = 3;
  static const _irqViewOffset = _abtViewOffset + _abtViewLength;
  static const _irqViewLength = 3;
  static const _undViewOffset = _irqViewOffset + _irqViewLength;
  static const _undViewLength = 3;

  /// Stack pointer index.
  @visibleForTesting
  static const SP = 13;

  /// Link register index.
  @visibleForTesting
  static const LR = 14;

  /// Program counter index.
  @visibleForTesting
  static const PC = 15;

  static const _totalRegisters = 37;

  // All memory locations, including those which are mode dependent or for CPSR.
  final Uint32List _registers;

  // Views into part of all the memory for specific operating modes.
  //
  // Prevents accidentally reading/writing to the wrong parts of the memory.
  final Uint32List _fiqView;
  final Uint32List _svcView;
  final Uint32List _abtView;
  final Uint32List _irqView;
  final Uint32List _undView;

  // Represents the CPSR.
  Arm7TdmiPsr _cpsr;

  /// Create a new empty register set.
  factory Arm7TdmiRegisters({
    Arm7TdmiOperatingMode operatingMode: Arm7TdmiOperatingMode.usr,
  }) {
    final registers = new Arm7TdmiRegisters.fromView(
      new Uint32List(_totalRegisters * Uint32List.BYTES_PER_ELEMENT),
    );
    registers.cpsr.operatingMode = operatingMode;
    return registers;
  }

  /// Returns a register set using an existing memory location.
  ///
  /// The following breakdown is assumed when using the memory:
  ///
  /// ```
  /// 00 -> 15  = R00 -> R15
  /// 16        = CPSR
  /// 17 -> 23  = R08 -> R14_fiq
  /// 24        = SPSR_fiq
  /// 25 -> 26  = R13 -> R15_svc
  /// 27        = SPSR_svc
  /// 28 -> 29  = R13 -> R15_abt
  /// 30        = SPSR_abt
  /// 31 -> 32  = R13 -> R15_irq
  /// 33        = SPSR_irq
  /// 34 -> 35  = R13 -> R15_und
  /// 36        = SPSR_und
  /// ```
  Arm7TdmiRegisters.fromView(Uint32List registers)
      :
        // 00 -> 15, plus 16 for the CPSR (17 registers).
        _registers = registers,

        // 17 -> 23, plus 24 for the SPSR_fiq (7 registers).
        _fiqView = new Uint32List.view(
          registers.buffer,
          _fiqViewOffset * Uint32List.BYTES_PER_ELEMENT,
          _fiqViewLength * Uint32List.BYTES_PER_ELEMENT,
        ),

        // 25 -> 26, plus 27 for the SPSR_svc (3 registers).
        _svcView = new Uint32List.view(
          registers.buffer,
          _svcViewOffset * Uint32List.BYTES_PER_ELEMENT,
          _svcViewLength * Uint32List.BYTES_PER_ELEMENT,
        ),

        // 28 -> 29, plus 30 for the SPSR_abt (3 registers).
        _abtView = new Uint32List.view(
          registers.buffer,
          _abtViewOffset * Uint32List.BYTES_PER_ELEMENT,
          _abtViewLength * Uint32List.BYTES_PER_ELEMENT,
        ),

        // 30 -> 32, plus 33 for the SPSR_irq (3 registers).
        _irqView = new Uint32List.view(
          registers.buffer,
          _irqViewOffset * Uint32List.BYTES_PER_ELEMENT,
          _irqViewLength * Uint32List.BYTES_PER_ELEMENT,
        ),

        // 34 -> 35, plus 36 for the SPSR_svc (3 registers).
        _undView = new Uint32List.view(
          registers.buffer,
          _undViewOffset * Uint32List.BYTES_PER_ELEMENT,
          _undViewLength * Uint32List.BYTES_PER_ELEMENT,
        ) {
    assert(() {
      if (_registers.length != _totalRegisters * Uint32List.BYTES_PER_ELEMENT) {
        throw new ArgumentError('${_registers.length}');
      }
      return true;
    });
    _cpsr = new Arm7TdmiPsr.fromView(_registers, 16);
  }

  /// Stack pointer.
  int get sp => _registers[SP];
  set sp(int sp) {
    _registers[SP] = sp;
  }

  /// Link register.
  int get lr => _registers[LR];
  set lr(int lr) {
    _registers[LR] = lr;
  }

  /// Program counter.
  int get pc => _registers[PC];
  set pc(int pc) {
    _registers[PC] = pc;
  }

  /// Current program status register bits.
  Arm7TdmiPsr get cpsr => _cpsr;

  /// Saved program status register bits.
  ///
  /// Memory location is dependant on `cpsr.operatingMode`.
  int get spsr {
    switch (cpsr.operatingMode) {
      case Arm7TdmiOperatingMode.fiq:
        return _fiqView[7];
      case Arm7TdmiOperatingMode.svc:
        return _svcView[3];
      case Arm7TdmiOperatingMode.abt:
        return _abtView[3];
      case Arm7TdmiOperatingMode.irq:
        return _irqView[3];
      case Arm7TdmiOperatingMode.und:
        return _undView[3];
      default:
        throw new UnsupportedError(
          'Cannot access SPSR as ${cpsr.operatingMode}',
        );
    }
  }

  set spsr(int spsr) {
    switch (cpsr.operatingMode) {
      case Arm7TdmiOperatingMode.fiq:
        _fiqView[7] = spsr;
        break;
      case Arm7TdmiOperatingMode.svc:
        _svcView[3] = spsr;
        break;
      case Arm7TdmiOperatingMode.abt:
        _abtView[3] = spsr;
        break;
      case Arm7TdmiOperatingMode.irq:
        _irqView[3] = spsr;
        break;
      case Arm7TdmiOperatingMode.und:
        _undView[3] = spsr;
        break;
      default:
        throw new UnsupportedError(
          'Cannot access SPSR as ${cpsr.operatingMode}',
        );
    }
  }

  /// Returns a [register] value.
  ///
  /// The memory location accessed is dependent on the operating mode.
  int get(int register) {
    assert(() {
      if (register < 0 || register > 15) {
        throw new RangeError.range(register, 0, 15);
      }
      return true;
    });
    // For R0-R7 or R15 short-circuit directly to the (shared) registers.
    if (register < 8 || register == 15) {
      return _registers[register];
    }
    // For R8-R14, it's dependent on the operating mode.
    Uint32List view;
    switch (cpsr.operatingMode) {
      case Arm7TdmiOperatingMode.fiq:
        if (register < 15) {
          return _fiqView[register - 8];
        }
        view = _registers;
        break;
      case Arm7TdmiOperatingMode.svc:
        view = _svcView;
        break;
      case Arm7TdmiOperatingMode.abt:
        view = _abtView;
        break;
      case Arm7TdmiOperatingMode.irq:
        view = _irqView;
        break;
      case Arm7TdmiOperatingMode.und:
        view = _undView;
        break;
    }
    if (register > 12 && register < 15) {
      return view[register - 13];
    }
    // Assume that we directly read from the original registers.
    return _registers[register];
  }

  /// Sets a [register] [value].
  ///
  /// The memory location accessed is dependent on the operating mode.
  void set(int register, int value) {
    assert(() {
      if (register < 0 || register > 15) {
        throw new RangeError.range(register, 0, 15);
      }
      return true;
    });
    // For R0-R7 or R15 short-circuit directly to the (shared) registers.
    if (register < 8 || register == 15) {
      _registers[register] = value;
    }
    // For R8-R14, it's dependent on the operating mode.
    Uint32List view;
    switch (cpsr.operatingMode) {
      case Arm7TdmiOperatingMode.fiq:
        if (register < 15) {
          _fiqView[register - 8] = value;
          return;
        }
        view = _registers;
        break;
      case Arm7TdmiOperatingMode.svc:
        view = _svcView;
        break;
      case Arm7TdmiOperatingMode.abt:
        view = _abtView;
        break;
      case Arm7TdmiOperatingMode.irq:
        view = _irqView;
        break;
      case Arm7TdmiOperatingMode.und:
        view = _undView;
        break;
    }
    if (register > 12 && register < 15) {
      view[register - 13] = value;
      return;
    }
    // Assume that we directly read from the original registers.
    _registers[register] = value;
  }

  /// Returns a copy of the data backing the registers.
  Uint32List toFixedList() => new Uint32List.fromList(_registers);
}
