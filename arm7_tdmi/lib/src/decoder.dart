import 'package:arm7_tdmi/arm7_tdmi.dart';

/// "Decodes" a compiled ARM7/TDMI program so it can be executed in an emulator.
class Arm7TdmiDecoder {
  const Arm7TdmiDecoder();

  /// Decodes and compiles [instruction] into a decoded `ARM` instruction.
  decodeArm(int instruction) => throw new UnimplementedError();
}

const _last4BitsMask = 0xF0000000;

/// Instruction format for a type of `ARM` 32-bit instruction.
///
/// When creating a new format, it's required to provide a `formatMask`, or a
/// number that can be matched quickly against an instruction. See [createMask]
/// for a helper function:
///
/// ```
/// // Returns a 32-bit integer that will match a `0` at bit 27 and `0` at 26.
/// Arm7TdmiInstructionFormat.createMask({
///   27: 0,
///   26: 0,
/// });
/// ```
///
/// Also see `tool/create_mask.dart` for a command-line tool.
abstract class Arm7TdmiInstructionFormat {
  static int createMask(Map<int, int> matchingBits) {
    throw new UnimplementedError();
  }

  const Arm7TdmiInstructionFormat._();

  /// Whether [instruction] is of this format.
  bool isFormat(int instruction) => throw new UnimplementedError();

  /// Decodes the condition from [instruction].
  Arm7TdmiCondition cond(int instruction) {
    return new Arm7TdmiCondition.decode(instruction & _last4BitsMask);
  }

  /*?*/ decode(int instruction) => throw new UnimplementedError();
}

/// Instruction format for Data Processing/PSR transformer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 1 Opcode* S Rn***** Rd***** Operand2***************
/// ```
/*
class _DataProcessingOrPsrTransfer extends Arm7TdmiInstructionFormat {
  const _DataProcessingOrPsrTransfer(): super._(/*0x2000000*/);
}
*/
