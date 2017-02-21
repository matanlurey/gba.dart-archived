import 'package:gba/src/video/status_register.dart';
import 'package:test/test.dart';

void main() {
  group('$DisplayStatusRegister', () {
    DisplayStatusRegister register;

    void commonSetUp(int registerValue) {
      register = new DisplayStatusRegister(read: () => registerValue);
    }

    tearDown(() {
      // Make sure we never forget to call commonSetUp.
      register = null;
    });

    test('isVBlank should return true iff bit 0 is set', () {
      commonSetUp(0);
      expect(register.isVBlank, isFalse);
      commonSetUp(1);
      expect(register.isVBlank, isTrue);
    });

    test('isHBlank should return true iff bit 1 is set', () {
      commonSetUp(1);
      expect(register.isHBlank, isFalse);
      commonSetUp(2);
      expect(register.isHBlank, isTrue);
    });

    test('isVCountTrigger should return true iff bit 2 is set', () {
      commonSetUp(3);
      expect(register.isVCountTrigger, isFalse);
      commonSetUp(4);
      expect(register.isVCountTrigger, isTrue);
    });

    test('isVBlankInterruptRequestSet should return true iff bit 3 is set', () {
      commonSetUp(7);
      expect(register.isVBlankInterruptRequestSet, isFalse);
      commonSetUp(8);
      expect(register.isVBlankInterruptRequestSet, isTrue);
    });

    test('isHBlankInterruptRequestSet should return true iff bit 4 is set', () {
      commonSetUp(15);
      expect(register.isHBlankInterruptRequestSet, isFalse);
      commonSetUp(16);
      expect(register.isHBlankInterruptRequestSet, isTrue);
    });

    test('isVCountInterruptRequestSet should return true iff bit 5 is set', () {
      commonSetUp(31);
      expect(register.isVCountInterruptRequestSet, isFalse);
      commonSetUp(32);
      expect(register.isVCountInterruptRequestSet, isTrue);
    });

    test('vCountTrigger should return the high 8 bits of the register', () {
      commonSetUp(0x0A00);
      expect(register.vCountTrigger, 0x0A);
      commonSetUp(0xFF00);
      expect(register.vCountTrigger, 0xFF);
      commonSetUp(0xFAA00);
      expect(register.vCountTrigger, 0xAA);
    });
  });
}
