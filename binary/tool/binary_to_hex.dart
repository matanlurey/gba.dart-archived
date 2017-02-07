import 'package:binary/binary.dart';

main() {
  const [
    ///////Cond*** 0 0 1 Opcode* S Rn***** Rd***** Operand2***************
    /***/ '0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0',
  ].forEach((string) {
    final bits = string.split(' ').map(int.parse).toList();
    final i = fromBits(bits);
    print(uint32.toBinaryPadded(i) + ': 0x' + i.toRadixString(16));
  });
}
