import 'dart:typed_data';

import 'package:arm7_tdmi/src/cpu/operating_modes.dart';
import 'package:arm7_tdmi/src/cpu/psr.dart';
import 'package:meta/meta.dart';

/// ARM7/TDMI processor.
class Cpu {
  /// Current program status registers.
  final ProgramStatusRegisters currentProgramStatusRegister;

  /// Stores the current value of a CPSR when an exception is taken.
  ///
  /// CPSR can be restored after handling the exception. Each exception handling
  /// mode can access its own SPSR. User mode and system mode do not have an
  /// SPSR because they are not exception handling modes.
  ///
  /// The execution state bits, including the endianness state and current
  /// instruction set state can be accessed from the SPSR in any exception mode,
  /// using the `MSR` and `MRS` instruction. You cannot access the SPSR using
  /// `MSR` or `MRS` in User or System mode.
  final ProgramStatusRegisters savedProgramStatusRegister;

  /// Normal `R0-R15` registers.
  ///
  /// - R0-R7 are known as the "low" registers.
  /// - R8-R12 are known as the "high" registers.
  /// - R13 is the stack pointer.
  /// - R14 is the link pointer.
  /// - R15 is the program counter.
  final Uint32List registers;

  /// Used to copy back the R8-R14 state for normal operations.
  final Uint32List registersUsr;

  /// Fast IRQ mode registers (R8-14).
  final Uint32List registersFiq;

  /// Supervisor mode registers (R13-R14).
  final Uint32List registersSvc;

  /// Abort mode registers (R13-R14).
  final Uint32List registersAbt;

  /// IRQ mode registers (R13-R14).
  final Uint32List registersIrq;

  /// Undefined mode registers (R13-R14).
  final Uint32List registersUnd;

  /// The processor's current operating mode.
  ///
  /// Defaults to [OperatingMode.user].
  OperatingMode operatingMode;

  factory Cpu() {
    return new Cpu.from(
      currentProgramStatusRegister: new ProgramStatusRegisters(),
      savedProgramStatusRegister: new ProgramStatusRegisters(),
      registers: new Uint32List(16),
      registersUsr: new Uint32List(7),
      registersFiq: new Uint32List(7),
      registersSvc: new Uint32List(2),
      registersAbt: new Uint32List(2),
      registersIrq: new Uint32List(2),
      registersUnd: new Uint32List(2),
      operatingMode: OperatingMode.user,
    );
  }

  Cpu.from({
    @required this.currentProgramStatusRegister,
    @required this.savedProgramStatusRegister,
    @required this.registers,
    @required this.registersUsr,
    @required this.registersFiq,
    @required this.registersSvc,
    @required this.registersAbt,
    @required this.registersIrq,
    @required this.registersUnd,
    @required this.operatingMode,
  });

  int get linkRegister => registers[14];
  set linkRegister(int linkRegister) {
    registers[14] = linkRegister;
  }

  int get programCounter => registers[15];
  set programCounter(int programCounter) {
    registers[15] = programCounter;
  }

  int get stackPointer => registers[13];
  set stackPointer(int stackPointer) {
    registers[13] = stackPointer;
  }
}
