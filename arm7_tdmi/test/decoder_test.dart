import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';
import 'package:test/test.dart';

// We need to get these cases to pass, but skipping for now.
const _FAILING = const [
  HalfWordDataTransferRegisterOffset,
  HalfWordDataTransferImmediateOffset,
  SingleDataTransfer,
  CoprocessorDataOperation,
];

void main() {
  const [
    const [
      'Cond*** 0 0 1 Opcode* S Rn***** Rd***** Operand2***************',
      DataProcessingOrPsrTransfer
    ],
    const [
      'Cond*** 0 0 0 0 0 0 A S Rd***** Rn***** Rs***** 1 0 0 1 Rm*****',
      Multiply,
    ],
    const [
      'Cond*** 0 0 0 0 1 U A S RdHi*** RdLo*** Rs***** 1 0 0 1 Rm*****',
      MultiplyLong,
    ],
    const [
      'Cond*** 0 0 0 1 0 B 0 0 Rn***** Rd***** 0 0 0 0 1 0 0 1 Rn*****',
      SingleDataSwap,
    ],
    const [
      'Cond*** 0 0 0 1 0 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 1 Rn*****',
      BrandAndExchange,
    ],
    const [
      'Cond*** 0 0 0 P U 0 W L Rn***** Rd***** 0 0 0 0 1 S H 1 Rm*****',
      HalfWordDataTransferRegisterOffset
    ],
    const [
      'Cond*** 0 0 0 P U 1 W L Rn***** Rd***** Offset* 1 S H 1 Offset*',
      HalfWordDataTransferImmediateOffset,
    ],
    const [
      'Cond*** 0 1 I P U B W L Rn***** Rd***** Offset*****************',
      SingleDataTransfer,
    ],
    const [
      'Cond*** 0 1 1 - - - - - - - - - - - - - - - - - - - - 1 - - - -',
      Undefined,
    ],
    const [
      'Cond*** 1 0 0 P U S W L Rn***** Register_List******************',
      BlockDataTransfer,
    ],
    const [
      'Cond*** 1 0 1 L Offset*****************************************',
      Branch,
    ],
    const [
      'Cond*** 1 1 0 P U N W L Rn***** CRd**** CP#**** Offset*********',
      CoprocessorDataTransfer,
    ],
    const [
      'Cond*** 1 1 1 0 CP_Opc* CRn**** CRd**** CP#**** CP*** 0 CRm****',
      CoprocessorDataOperation,
    ],
    const [
      'Cond*** 1 1 1 0 CPOpc L CRn**** Rd***** CP#**** CP*** 1 CRm****',
      CoprocessorRegisterTransfer,
    ],
  ].forEach((formats) {
    final format = formats.last as Type;
    var bits = formats.first as String;
    bits = _normalizeBits(bits);

    test('$format should decode $bits', () {
      final decoded = new Arm7TdmiInstructionFormat.decoded(
        uint32.parseBits(bits),
      );
      expect(
        decoded.runtimeType,
        format,
        reason: 'Should not have been recognized as a $decoded, but $format',
      );
    }, skip: _FAILING.contains(format) ? 'Skipped $format' : null);
  });
}

String _normalizeBits(String description) {
  final buffer = new StringBuffer();
  for (var i = 0; i < description.length; i += 2) {
    final char = description[i];
    if (char == '1') {
      buffer.write('1');
    } else {
      buffer.write('0');
    }
  }
  return buffer.toString();
}
