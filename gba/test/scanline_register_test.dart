import 'package:gba/src/video/scanline_register.dart';
import 'package:test/test.dart';

void main() {
  group('$ScanlineRegister', () {
    ScanlineRegister register;

    test('lineNumber should return the correct 8-bit line number', () {
      void expectLine(ScanlineRegister register, int line) {
        expect(register.lineNumber, line);
      }

      // For lines <= 2^8 - 1
      expectLine(new ScanlineRegister(read: () => 0x0), 0);
      expectLine(new ScanlineRegister(read: () => 0x64), 100);
      expectLine(new ScanlineRegister(read: () => 0xFF), 255);
      // For lines > 2^8 - 1
      expectLine(new ScanlineRegister(read: () => 0xFFF), 255);
    });
  });
}
