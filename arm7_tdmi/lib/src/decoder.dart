import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/utils/bits.dart';

/// "Decodes" a compiled ARM7/TDMI program so it can be executed in an emulator.
class Arm7TdmiDecoder {
  const Arm7TdmiDecoder();

  /// Decodes and compiles [instruction] into an understood `ARM` instruction.
  decode(int instruction) {
    assert(() {
      if (instruction == null) {
        throw new ArgumentError.notNull('instruction');
      }
      return true;
    });
  }

  // Data processing/PSR transfer.
  //
  // 11:00 -> Operand2
  // 15:12 -> Rd
  // 19:16 -> Rn
  // 20:20 -> S
  // 24:21 -> Opcode
  // 25:25 -> I
  // 26:26 -> (0)
  // 27:27 -> (0)
  // 31:28 -> Cond
  _armDataProcessing(
    int instruction,
  ) {
    throw new UnimplementedError();
  }
}

const _last4BitsMask = 0xF0000000;

abstract class Arm7TdmiInstructionFormat {
  final int _formatMask;

  const Arm7TdmiInstructionFormat._(this._formatMask);

  /// Whether [instruction] is of this format.
  bool isFormat(int instruction) => isSet(instruction & _formatMask);

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
class _DataProcessingOrPsrTransfer extends Arm7TdmiInstructionFormat {
  const _DataProcessingOrPsrTransfer(): super._(0x1000000);
}
