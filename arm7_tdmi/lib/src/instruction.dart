import 'package:arm7_tdmi/arm7_tdmi.dart';
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

    final op1 = _mask(gprs.get(rn), 32);
    final op2 = _mask(format.operand(instruction), 32);
    final result = op1 + op2;

    gprs.set(rd, result);

    // TODO: If updatesSpsr.

    gprs.cpsr
      ..n = false /*int32.sign(result)*/
      ..z = gprs.get(rd) == 0
      ..c = false /*int32.hasCarryBit(result)*/
      ..v = false /*int32.isAddOverflow(op1, op2, result)*/;
  }
}

// TODO: Remove this once #35 lands.
int _mask(int bits, int length) => bits & ~(~0 << length);
