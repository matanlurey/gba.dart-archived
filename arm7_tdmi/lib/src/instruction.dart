library arm7_tdmi.src.instruction;

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';
import 'package:meta/meta.dart';

part 'instruction/adc.dart';
part 'instruction/adcs.dart';
part 'instruction/add.dart';
part 'instruction/adds.dart';
part 'instruction/ldr.dart';
part 'instruction/mov.dart';
part 'instruction/movs.dart';
part 'instruction/swi.dart';

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
  /// Format.
  final F format;

  /// Opcode.
  final int opcode;

  /// Suffix mnemonic.
  final String suffix;

  const Arm7TdmiInstruction._({
    @required this.format,
    @required this.opcode,
    @required this.suffix,
  });

  /// Executes this instruction.
  ///
  /// Subclasses have additional named parameters that are required.
  void execute();

  /// Interprets an [instruction] of [format] on a [cpu].
  ///
  /// Returns whether the instruction was executed.
  bool interpret(Arm7Tdmi cpu, int instruction);

  /// Returns whether [cpu] is in a state where [instruction] passes.
  @protected
  bool passes(Arm7Tdmi cpu, int instruction) {
    return true;
    // TODO: Enable once hello_world_test passes.
    // final condition = new Arm7TdmiCondition.decode(instruction);
    // return condition.passes(cpu.gprs.cpsr);
  }
}

const ADD = const ADD$._();
const ADDS = const ADDS$._();
const ADC = const ADC$._();
const ADCS = const ADCS$._();
const MOV = const MOV$._();
const MOVS = const MOVS$._();
const SWI = const SWI$._();
const LDR = const LDR$._();
