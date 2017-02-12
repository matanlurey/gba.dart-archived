import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';

/// An ARM7/TDMI instruction definition.
///
/// ## Logical
///
/// ```
/// Instruction                         Cycles      Flags       Explanation
/// ----------------------------------------------------------------------------
/// MOV{cond}{S} Rd,Op2                 1S+x+y      NZc-        Rd = Op2
/// ```
abstract class Arm7TdmiInstruction<F extends Arm7TdmiInstructionFormat> {
  /// Opcode.
  final int opcode;

  /// Suffix mnemonic.
  final String suffix;

  const Arm7TdmiInstruction._({
    @required this.opcode,
    @required this.suffix,
  });

  /// Executes an [instruction] of [format] on a [cpu].
  ///
  /// Returns whether the instruction was executed.
  @mustCallSuper
  @protected
  bool execute(Arm7Tdmi cpu, F format, int instruction) {
    return format.cond(instruction).passes(cpu.gprs.cpsr);
  }
}

/// An `ADD` instruction.
const Arm7TdmiInstruction<DataProcessingOrPsrTransfer> ADD = const _ADD();
const Arm7TdmiInstruction<DataProcessingOrPsrTransfer> ADDS = const _ADDS();
const Arm7TdmiInstruction<DataProcessingOrPsrTransfer> ADC = const _ADC();
const Arm7TdmiInstruction<DataProcessingOrPsrTransfer> ADCS = const _ADCS();
const Arm7TdmiInstruction<DataProcessingOrPsrTransfer> MOV = const _MOV();
const Arm7TdmiInstruction<DataProcessingOrPsrTransfer> MOVS = const _MOVS();
const Arm7TdmiInstruction<SoftwareInterrupt> SWI = const _SWI();
const Arm7TdmiInstruction<DataProcessingOrPsrTransfer> LDR = const _LDR();

class _ADD extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const _ADD() : super._(opcode: 0, suffix: 'ADD');

  @override
  bool execute(
    Arm7Tdmi cpu,
    DataProcessingOrPsrTransfer format,
    int instruction,
  ) {
    if (!super.execute(cpu, format, instruction)) return false;

    final gprs = cpu.gprs;
    final rd = format.rd(instruction);
    final rn = format.rn(instruction);
    final op1 = int32.mask(gprs.get(rn));
    final op2 = int32.mask(format.operand(instruction));
    final result = op1 + op2;

    gprs.set(rd, result);
    return true;
  }
}

class _ADDS extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const _ADDS() : super._(opcode: 0, suffix: 'ADDS');

  @override
  bool execute(
    Arm7Tdmi cpu,
    DataProcessingOrPsrTransfer format,
    int instruction,
  ) {
    if (!super.execute(cpu, format, instruction)) return false;

    final gprs = cpu.gprs;
    final rd = format.rd(instruction);
    final rn = format.rn(instruction);
    final op1 = int32.mask(gprs.get(rn));
    final op2 = int32.mask(format.operand(instruction));
    final result = op1 + op2;

    gprs.set(rd, result);

    // TODO: If rd == program counter.

    gprs.cpsr
      ..n = int32.isNegative(result)
      ..z = isZero(gprs.get(rd))
      ..c = int32.hasCarryBit(result)
      ..v = int32.doesAddOverflow(op1, op2, result);
    return true;
  }
}

class _ADC extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const _ADC() : super._(opcode: 5, suffix: 'ADC');

  @override
  bool execute(
    Arm7Tdmi cpu,
    DataProcessingOrPsrTransfer format,
    int instruction,
  ) {
    if (!super.execute(cpu, format, instruction)) return false;

    final gprs = cpu.gprs;
    final rd = format.rd(instruction);
    final rn = format.rn(instruction);
    final op1 = int32.mask(gprs.get(rn));
    final op2 = int32.mask(format.operand(instruction)) + (gprs.cpsr.c ? 1 : 0);
    final result = op1 + op2;

    gprs.set(rd, result);
    return true;
  }
}

class _ADCS extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const _ADCS() : super._(opcode: 5, suffix: 'ADCS');

  @override
  bool execute(
    Arm7Tdmi cpu,
    DataProcessingOrPsrTransfer format,
    int instruction,
  ) {
    if (!super.execute(cpu, format, instruction)) return false;

    final gprs = cpu.gprs;
    final rd = format.rd(instruction);
    final rn = format.rn(instruction);
    final op1 = int32.mask(gprs.get(rn));
    final op2 = int32.mask(format.operand(instruction)) + (gprs.cpsr.c ? 1 : 0);
    final result = op1 + op2;

    gprs.set(rd, result);

    // TODO: rd == program counter.

    gprs.cpsr
      ..n = int32.isNegative(result)
      ..z = isZero(gprs.get(rd))
      ..c = int32.hasCarryBit(result)
      ..v = int32.doesAddOverflow(op1, op2, result);
    return true;
  }
}

class _SWI extends Arm7TdmiInstruction<SoftwareInterrupt> {
  const _SWI() : super._(opcode: null, suffix: 'SWI');

  @override
  bool execute(
    Arm7Tdmi cpu,
    SoftwareInterrupt format,
    int instruction,
  ) {
    if (!super.execute(cpu, format, instruction)) return false;
    // TODO: implement execute
    return true;
  }
}

class _MOV extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const _MOV() : super._(opcode: 13, suffix: 'MOV');

  @override
  bool execute(
    Arm7Tdmi cpu,
    DataProcessingOrPsrTransfer format,
    int instruction,
  ) {
    if (!super.execute(cpu, format, instruction)) return false;

    final gprs = cpu.gprs;
    final rd = format.rd(instruction);
    final shifterOperand = format.operand(instruction);

    gprs.set(rd, shifterOperand);
    return true;
  }
}

class _MOVS extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const _MOVS() : super._(opcode: 13, suffix: 'MOVS');

  @override
  bool execute(
    Arm7Tdmi cpu,
    DataProcessingOrPsrTransfer format,
    int instruction,
  ) {
    if (!super.execute(cpu, format, instruction)) return false;

    final gprs = cpu.gprs;
    final rd = format.rd(instruction);
    final shifterOperand = format.operand(instruction);

    gprs.set(rd, shifterOperand);

    // TODO: If rd == program counter.

    gprs.cpsr
      ..n = int32.isNegative(gprs.get(rd))
      ..z = isZero(gprs.get(rd))
      // TODO: Update this to shifterCarryOut once implemented.
      ..c = true;
    return true;
  }
}

// TODO(kharland): Figure out the correct format for this instruction and fix
// hello world test.
class _LDR extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const _LDR() : super._(opcode: null, suffix: 'LDR');

  @override
  bool execute(
    Arm7Tdmi cpu,
    DataProcessingOrPsrTransfer format,
    int instruction,
  ) {
    if (!super.execute(cpu, format, instruction)) return false;
    // TODO: implement execute
    return true;
  }
}
