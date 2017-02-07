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
abstract class Arm7TdmiInstruction {
  // Logical.
  static const MOV = const _Move();

  /// Opcode.
  final int opcode;

  /// Suffix mnemonic.
  final String suffix;

  const Arm7TdmiInstruction._({
    @required
    this.opcode,
    @required
    this.suffix,
  });

  void execute(Arm7Tdmi cpu, int rd, rn, shiftOp, condOp);
}

class _Move extends Arm7TdmiInstruction {
  const _Move() : super._(
    opcode: 0x01A00000,
    suffix: 'MOV',
  );

  @override
  void execute(Arm7Tdmi cpu, int rd, rn, shiftOp, condOp) {
    throw new UnimplementedError();
  }
}
