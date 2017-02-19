import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';

/// "Decodes" a compiled ARM7/TDMI program so it can be executed in an emulator.
class Arm7TdmiDecoder {
  const Arm7TdmiDecoder();

  /// Decodes and compiles [instruction] into a decoded `ARM` instruction.
  /*?*/ decodeArm(int instruction) {
    final format = new Arm7TdmiInstructionFormat.decoded(instruction);
    assert(format != null);
  }
}

const _last4BitsMask = 0xF0000000;

/// Instruction format for a type of `ARM` 32-bit instruction.
///
/// When creating a new format, it's required to provide a `formatMask`, or a
/// number that can be matched quickly against an instruction.
abstract class Arm7TdmiInstructionFormat {
  /// All known ARM7/TDMI instruction formats.
  ///
  /// **NOTE**: The ordering is significant when decoding a format.
  static const List<Arm7TdmiInstructionFormat> formats = const [
    const SoftwareInterrupt(),
    const CoprocessorRegisterTransfer(),
    const CoprocessorDataOperation(),
    const CoprocessorDataTransfer(),
    const Branch(),
    const BlockDataTransfer(),
    const Undefined(),
    const SingleDataTransfer(),
    const DataProcessingOrPsrTransfer(),
    const HalfWordDataTransferImmediateOffset(),
    const HalfWordDataTransferRegisterOffset(),
    const BrandAndExchange(),
    const SingleDataSwap(),
    const MultiplyLong(),
    const Multiply(),
  ];

  static int _computeFormat(int instruction) =>
      (uint32.range(instruction, 27, 20) << 4) |
      (uint32.range(instruction, 7, 4));

  final int _formatMask;

  /// Returns the format of [instruction].
  factory Arm7TdmiInstructionFormat.decoded(int instruction) {
    final computed = _computeFormat(instruction);
    for (final format in formats) {
      if (format.isFormat(computed)) {
        return format;
      }
    }
    throw new ArgumentError.value(
      instruction,
      'instruction',
      'No matching format: $computed.',
    );
  }

  const Arm7TdmiInstructionFormat._(this._formatMask);

  /// Whether [instruction] is of this format.
  bool isFormat(int instruction) => instruction & _formatMask == _formatMask;

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
class DataProcessingOrPsrTransfer extends Arm7TdmiInstructionFormat {
  const DataProcessingOrPsrTransfer() : super._(0x200);

  /// Returns what register to write to.
  int rd(int instruction) => 0;

  /// Returns what register to read from.
  int rn(int instruction) => 0;

  /// Type of operand to use.
  int operand(int instruction) => 0;
}

/// Instruction format for Multiply.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 0 0 0 A S Rd***** Rn***** Rs***** 1 0 0 1 Rm*****
/// ```
class Multiply extends Arm7TdmiInstructionFormat {
  const Multiply() : super._(0x009);
}

/// Instruction format for Multiply Long.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 0 1 U A S RdHi*** RdLo*** Rs***** 1 0 0 1 Rm*****
/// ```
class MultiplyLong extends Arm7TdmiInstructionFormat {
  const MultiplyLong() : super._(0x089);
}

/// Instruction format for Single Data Swap.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 1 0 B 0 0 Rn***** Rd***** 0 0 0 0 1 0 0 1 Rn*****
/// ```
class SingleDataSwap extends Arm7TdmiInstructionFormat {
  const SingleDataSwap() : super._(0x109);
}

/// Instruction format for Branch and Exchange.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 1 0 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 1 Rn*****
/// ```
class BrandAndExchange extends Arm7TdmiInstructionFormat {
  const BrandAndExchange() : super._(0x121);
}

/// Instruction format for Half-word Data Transfer: Register offset.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 P U 0 W L Rn***** Rd***** 0 0 0 0 1 S H 1 Rm*****
/// ```
class HalfWordDataTransferRegisterOffset extends Arm7TdmiInstructionFormat {
  const HalfWordDataTransferRegisterOffset() : super._(0x00B);
}

/// Instruction format for Half-word Data Transfer: Immediate offset.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 P U 1 W L Rn***** Rd***** Offset* 1 S H 1 Offset*
/// ```
class HalfWordDataTransferImmediateOffset extends Arm7TdmiInstructionFormat {
  const HalfWordDataTransferImmediateOffset() : super._(0x04B);
}

/// Instruction format for Single Data Transfer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 1 I P U B W L Rn***** Rd***** Offset*****************
/// ```
class SingleDataTransfer extends Arm7TdmiInstructionFormat {
  const SingleDataTransfer() : super._(0x600);
}

/// Instruction format for Undefined.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 1 1 - - - - - - - - - - - - - - - - - - - - 1 - - - -
/// ```
class Undefined extends Arm7TdmiInstructionFormat {
  const Undefined() : super._(0x601);
}

/// Instruction format for Block Data Transfer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 0 0 P U S W L Rn***** Register_List******************
/// ```
class BlockDataTransfer extends Arm7TdmiInstructionFormat {
  const BlockDataTransfer() : super._(0x800);
}

/// Instruction format for Branch.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 0 1 L Offset*****************************************
/// ```
class Branch extends Arm7TdmiInstructionFormat {
  const Branch() : super._(0xA00);
}

/// Instruction format for Coprocessor Data Transfer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 1 0 P U N W L Rn***** CRd**** CP#**** Offset*********
/// ```
class CoprocessorDataTransfer extends Arm7TdmiInstructionFormat {
  const CoprocessorDataTransfer() : super._(0xC00);
}

/// Instruction format for Coprocessor Data Operation.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 1 1 0 CP_Opc* CRn**** CRd**** CP#**** CP*** 0 CRm****
/// ```
class CoprocessorDataOperation extends Arm7TdmiInstructionFormat {
  const CoprocessorDataOperation() : super._(0xE00);
}

/// Instruction format for Coprocessor Register Transfer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 1 1 0 CPOpc L CRn**** Rd***** CP#**** CP*** 1 CRm****
/// ```
class CoprocessorRegisterTransfer extends Arm7TdmiInstructionFormat {
  const CoprocessorRegisterTransfer() : super._(0xE00);
}

/// Instruction format for Software Interrupt.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 1 1 1 1 (Ignored by processor*************************)
/// ```
class SoftwareInterrupt extends Arm7TdmiInstructionFormat {
  const SoftwareInterrupt() : super._(0xE01);
}
