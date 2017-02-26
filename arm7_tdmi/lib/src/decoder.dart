import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/instruction.dart';
import 'package:binary/binary.dart';

/// "Decodes" a compiled ARM7/TDMI program so it can be executed in an emulator.
class Arm7TdmiDecoder {
  // Bits 27-20 (high) and 7-4 (base) added end-to-end.
  static int _compute12Bits(int instruction) =>
      (((instruction >> 16) & 0xFF0) | ((instruction >> 4) & 0x0F));

  const Arm7TdmiDecoder();

  /// Decodes and compiles [instruction] into a decoded `ARM` instruction.
  Arm7TdmiInstruction decodeArm(int instruction) {
    final format = decodeArmFormat(instruction);
    assert(format != null);
    return format.decode(instruction);
  }

  Arm7TdmiInstructionFormat decodeArmFormat(int instruction) {
    final computed = _compute12Bits(instruction);
    for (final format in Arm7TdmiInstructionFormat.formats) {
      if (format.isFormat(computed)) {
        return format;
      }
    }
    // TODO: Remove once isFormat works for this format type.
    if (instruction & 0x00000090 == 0x00000090) {
      return const HalfWordDataTransferRegisterOffset();
    }
    throw new ArgumentError.value(
      instruction,
      'instruction',
      'No matching format: $computed.',
    );
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
    const HalfWordDataTransferImmediateOffset(),
    const HalfWordDataTransferRegisterOffset(),
    const BrandAndExchange(),
    const SingleDataSwap(),
    const MultiplyLong(),
    const Multiply(),
    const DataProcessingOrPsrTransfer(),
  ];

  final int _formatMask;

  const Arm7TdmiInstructionFormat._(this._formatMask);

  /// Whether [computed] is of this format.
  bool isFormat(int computed) => computed & _formatMask == _formatMask;

  /// Decodes the condition from [instruction].
  Arm7TdmiCondition cond(int instruction) {
    return new Arm7TdmiCondition.decode(instruction & _last4BitsMask);
  }

  /// Returns ARM instruction type for this format by decoding [instruction].
  Arm7TdmiInstruction decode(int instruction);
}

void _assertValidOpcode(
  Arm7TdmiInstruction decoded,
  int instruction,
  int opcode,
) {
  assert(() {
    if (decoded == null) {
      throw new ArgumentError.value(
        instruction,
        'instruction',
        'Unrecognized or supported opcode: $opcode',
      );
    }
    return true;
  });
}

/// Instruction format for Data Processing/PSR transformer.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 Opcode* S Rn***** Rd***** Operand2***************
/// ```
class DataProcessingOrPsrTransfer extends Arm7TdmiInstructionFormat {
  static const _opAND = 0x0;
  static const _opEOR = 0x1;
  static const _opSUB = 0x2;
  static const _opRSB = 0x3;
  static const _opADD = 0x4;
  static const _opADC = 0x5;
  static const _opSBC = 0x6;
  static const _opRSC = 0x7;
  static const _opTST = 0x8;
  static const _opTEQ = 0x9;
  static const _opCMP = 0xA;
  static const _opCMN = 0xB;
  static const _opORR = 0xC;
  static const _opMOV = 0xD;
  static const _opBIC = 0xE;
  static const _opMVN = 0xF;

  const DataProcessingOrPsrTransfer() : super._(0x0);

  @override
  Arm7TdmiInstruction decode(int instruction) {
    final opcode = this.opcode(instruction);
    final decoded = const {
      _opAND: null,
      _opEOR: null,
      _opSUB: null,
      _opRSB: null,
      _opADD: ADD,
      _opADC: ADC,
      _opSBC: null,
      _opRSC: null,
      _opTST: null,
      _opTEQ: null,
      _opCMP: null,
      _opCMN: null,
      _opORR: null,
      _opMOV: MOV,
      _opBIC: null,
      _opMVN: null,
    }[opcode];
    _assertValidOpcode(decoded, instruction, opcode);
    return decoded;
  }

  /// Instruction type.
  int opcode(int instruction) => uint32.range(instruction, 24, 21);

  /// Returns whether `S` is set.
  int s(int instruction) => uint32.get(instruction, 20);

  /// Returns what register to read from.
  int rn(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns what register to write to.
  int rd(int instruction) => uint32.range(instruction, 15, 12);

  /// Type of operand to use.
  int operand(int instruction) => uint32.range(instruction, 11, 0);
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
  const Multiply() : super._(0x9);

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  /// Returns whether `A` is set.
  int a(int instruction) => uint32.get(instruction, 21);

  /// Returns whether `S` is set.
  int s(int instruction) => uint32.get(instruction, 20);

  /// Returns what register to write to.
  int rd(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns what register to read from.
  int rn(int instruction) => uint32.range(instruction, 15, 12);

  /// Returns ???.
  int rs(int instruction) => uint32.range(instruction, 11, 8);

  /// Returns ???.
  int rm(int instruction) => uint32.range(instruction, 3, 0);
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
  const MultiplyLong() : super._(0x89);

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  /// Returns whether `A` is set.
  int a(int instruction) => uint32.get(instruction, 21);

  /// Returns ???.
  int rdHi(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns ???.
  int rdLo(int instruction) => uint32.range(instruction, 15, 12);

  /// Returns whether `S` is set.
  int s(int instruction) => uint32.get(instruction, 20);

  /// Returns whether `U` is set.
  int u(int instruction) => uint32.get(instruction, 21);

  /// Returns ???.
  int rs(int instruction) => uint32.range(instruction, 11, 8);

  /// Returns ???.
  int rm(int instruction) => uint32.range(instruction, 3, 0);
}

/// Instruction format for Single Data Swap.
///
/// ```
/// 3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 9 8 7 6 5 4 3 2 1 0
/// 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
/// ---------------------------------------------------------------
/// Cond*** 0 0 0 1 0 B 0 0 Rn***** Rd***** 0 0 0 0 1 0 0 1 Rm*****
/// ```
class SingleDataSwap extends Arm7TdmiInstructionFormat {
  const SingleDataSwap() : super._(0x109);

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  /// Returns ???.
  int b(int instruction) => uint32.get(instruction, 22);

  /// Returns what register to read from.
  int rn(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns what register to read from.
  int rd(int instruction) => uint32.range(instruction, 15, 12);

  /// Returns ???.
  int rm(int instruction) => uint32.range(instruction, 3, 0);
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

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  /// Returns what register to read from.
  int rn(int instruction) => uint32.range(instruction, 3, 0);
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
  const HalfWordDataTransferRegisterOffset() : super._(0x9);

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  // TODO: Figure out what the proper mask/logic is.
  @override
  bool isFormat(int computed) => false;

  /// Returns ???.
  int p(int instruction) => uint32.get(instruction, 24);

  /// Returns ???.
  int u(int instruction) => uint32.get(instruction, 23);

  /// Returns ???.
  int w(int instruction) => uint32.get(instruction, 21);

  /// Returns ???.
  int l(int instruction) => uint32.get(instruction, 20);

  /// Returns ???.
  int rn(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns ???.
  int rd(int instruction) => uint32.range(instruction, 15, 12);

  /// Returns ???.
  int s(int instruction) => uint32.get(instruction, 6);

  /// Returns ???.
  int h(int instruction) => uint32.get(instruction, 5);

  /// Returns ???.
  int rm(int instruction) => uint32.range(instruction, 3, 0);
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
  const HalfWordDataTransferImmediateOffset() : super._(0x49);

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  /// Returns ???.
  int p(int instruction) => uint32.get(instruction, 24);

  /// Returns ???.
  int u(int instruction) => uint32.get(instruction, 23);

  /// Returns ???.
  int w(int instruction) => uint32.get(instruction, 21);

  /// Returns ???.
  int l(int instruction) => uint32.get(instruction, 20);

  /// Returns ???.
  int rn(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns ???.
  int rd(int instruction) => uint32.range(instruction, 15, 12);

  /// Returns ???.
  int s(int instruction) => uint32.get(instruction, 6);

  /// Returns ???.
  int h(int instruction) => uint32.get(instruction, 5);

  /// Returns ???.
  int offset(int instruction) => uint32.range(instruction, 3, 0);
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
  const SingleDataTransfer() : super._(0x400);

  @override
  Arm7TdmiInstruction decode(int instruction) {
    if (isZero(l(instruction))) {
      throw new UnimplementedError('STR');
    } else {
      return LDR;
    }
  }

  /// Returns ???.
  int i(int instruction) => uint32.get(instruction, 25);

  /// Returns ???.
  int p(int instruction) => uint32.get(instruction, 24);

  /// Returns ???.
  int u(int instruction) => uint32.get(instruction, 23);

  /// Returns ???.
  int b(int instruction) => uint32.get(instruction, 22);

  /// Returns ???.
  int w(int instruction) => uint32.get(instruction, 21);

  /// Returns the load/store to memory bit (0=Store, 1=Load).
  int l(int instruction) => uint32.get(instruction, 20);

  /// Returns ???.
  int rn(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns ???.
  int rd(int instruction) => uint32.range(instruction, 15, 12);

  /// Returns ???.
  int offset(int instruction) => uint32.range(instruction, 11, 0);
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

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }
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

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  /// Returns ???.
  int p(int instruction) => uint32.get(instruction, 24);

  /// Returns ???.
  int u(int instruction) => uint32.get(instruction, 23);

  /// Returns ???.
  int s(int instruction) => uint32.get(instruction, 22);

  /// Returns ???.
  int w(int instruction) => uint32.get(instruction, 21);

  /// Returns ???.
  int l(int instruction) => uint32.get(instruction, 20);

  /// Returns ???.
  int rn(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns ???.
  int registerList(int instruction) => uint32.range(instruction, 15, 0);
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

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  /// Returns ???.
  int l(int instruction) => uint32.get(instruction, 24);

  /// Returns ???.
  int offset(int instruction) => uint32.range(instruction, 23, 0);
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

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  /// Returns ???.
  int p(int instruction) => uint32.get(instruction, 24);

  /// Returns ???.
  int u(int instruction) => uint32.get(instruction, 23);

  /// Returns ???.
  int n(int instruction) => uint32.get(instruction, 22);

  /// Returns ???.
  int w(int instruction) => uint32.get(instruction, 21);

  /// Returns ???.
  int l(int instruction) => uint32.get(instruction, 20);

  /// Returns ???.
  int rn(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns ???.
  int crD(int instruction) => uint32.range(instruction, 15, 12);

  /// Returns ???.
  int cpP(int instruction) => uint32.range(instruction, 11, 8);

  /// Returns ???.
  int offset(int instruction) => uint32.range(instruction, 7, 0);
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

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  /// Returns ???.
  int cpOpc(int instruction) => uint32.range(instruction, 23, 20);

  /// Returns ???.
  int crN(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns ???.
  int crD(int instruction) => uint32.range(instruction, 15, 12);

  /// Returns ???.
  int cpP(int instruction) => uint32.range(instruction, 11, 8);

  /// Returns ???.
  int cp(int instruction) => uint32.range(instruction, 7, 5);

  /// Returns ???.
  int crM(int instruction) => uint32.range(instruction, 3, 0);
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
  const CoprocessorRegisterTransfer() : super._(0xE01);

  @override
  Arm7TdmiInstruction decode(int instruction) {
    throw new UnimplementedError();
  }

  /// Returns ???.
  int cpOpc(int instruction) => uint32.range(instruction, 23, 21);

  /// Returns ???.
  int l(int instruction) => uint32.get(instruction, 20);

  /// Returns ???.
  int crN(int instruction) => uint32.range(instruction, 19, 16);

  /// Returns ???.
  int rd(int instruction) => uint32.range(instruction, 15, 12);

  /// Returns ???.
  int cpP(int instruction) => uint32.range(instruction, 11, 8);

  /// Returns ???.
  int cp(int instruction) => uint32.range(instruction, 7, 5);

  /// Returns ???.
  int crM(int instruction) => uint32.range(instruction, 3, 0);
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
  const SoftwareInterrupt() : super._(0xF00);

  @override
  Arm7TdmiInstruction decode(_) => SWI;
}
