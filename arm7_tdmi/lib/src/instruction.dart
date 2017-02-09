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
  void execute(Arm7Tdmi cpu, F format, int instruction);
}

/// An `ADD` instruction.
const Arm7TdmiInstruction<DataProcessingOrPsrTransfer> ADD = const _ADD();
const Arm7TdmiInstruction<DataProcessingOrPsrTransfer> ADC = const _ADC();

class _ADD extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const _ADD() : super._(opcode: 0, suffix: 'ADD');

  @override
  void execute(
    Arm7Tdmi cpu,
    DataProcessingOrPsrTransfer format,
    int instruction,
  ) {
    final gprs = cpu.gprs;
    final rd = format.rd(instruction);
    final rn = format.rn(instruction);

    final op1 = int32.mask(gprs.get(rn));
    final op2 = int32.mask(format.operand(instruction));
    final result = op1 + op2;

    gprs.set(rd, result);

    // TODO: If updatesSpsr && rd == program counter.

    gprs.cpsr
      ..n = int32.isNegative(result)
      ..z = gprs.get(rd) == 0
      ..c = int32.hasCarryBit(result)
      ..v = int32.doesAddOverflow(op1, op2, result);
  }
}

class _ADC extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const _ADC() : super._(opcode: 5, suffix: 'ADC');

  @override
  void execute(
    Arm7Tdmi cpu,
    DataProcessingOrPsrTransfer format,
    int instruction,
  ) {
    final gprs = cpu.gprs;
    final rd = format.rd(instruction);
    final rn = format.rn(instruction);
    final op1 = int32.mask(gprs.get(rn));
    final op2 = int32.mask(format.operand(instruction)) + (gprs.cpsr.c ? 1 : 0);
    final result = op1 + op2;

    gprs.set(rd, result);

    // TODO: If updatesSpsr && rd == program counter.

    gprs.cpsr
      ..n = int32.isNegative(result)
      ..z = gprs.get(rd) == 0
      ..c = int32.hasCarryBit(result)
      ..v = int32.doesAddOverflow(op1, op2, result);
  }
}
