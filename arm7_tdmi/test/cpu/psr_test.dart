import 'package:arm7_tdmi/src/cpu/psr.dart';
import 'package:arm7_tdmi/src/utils/bits.dart';
import 'package:test/test.dart';

void main() {
  group('$StatusRegister', () {
    StatusRegister sr;

    setUp(() {
      sr = new StatusRegister();
    });

    test('signed/unsigned should read and write bit 31.', () {
      expect(sr.isSigned, isFalse);
      expect(isSet(getBit(31, sr.word)), isFalse);

      sr.setSigned();
      expect(sr.isSigned, isTrue);
      expect(isSet(getBit(31, sr.word)), isTrue);

      sr.setUnsigned();
      expect(sr.isSigned, isFalse);
      expect(isSet(getBit(31, sr.word)), isFalse);
    });

    test('zero/nonZero should read and write bit 30', () {
      expect(sr.isZero, isFalse);
      expect(isSet(getBit(30, sr.word)), isFalse);

      sr.setZero();
      expect(sr.isZero, isTrue);
      expect(isSet(getBit(30, sr.word)), isTrue);

      sr.setNonZero();
      expect(sr.isZero, isFalse);
      expect(isSet(getBit(30, sr.word)), isFalse);
    });

    test('carry/borrow should read and write bit 29', () {
      expect(sr.isCarry, isFalse);
      expect(isSet(getBit(29, sr.word)), isFalse);

      sr.enableCarry();
      expect(sr.isCarry, isTrue);
      expect(isSet(getBit(29, sr.word)), isTrue);

      sr.disableCarry();
      expect(sr.isCarry, isFalse);
      expect(isSet(getBit(29, sr.word)), isFalse);
    });

    test('overflow should read and write bit 28', () {
      expect(sr.isOverflow, isFalse);
      expect(isSet(getBit(28, sr.word)), isFalse);

      sr.enableOverflow();
      expect(sr.isOverflow, isTrue);
      expect(isSet(getBit(28, sr.word)), isTrue);

      sr.disableOverflow();
      expect(sr.isOverflow, isFalse);
      expect(isSet(getBit(28, sr.word)), isFalse);
    });

    test('fast interrupts should set bit 6.', () {
      expect(sr.isFastInterruptsDisabled, isFalse);
      expect(isSet(getBit(6, sr.word)), isFalse);

      sr.disableFastInterrupts();
      expect(sr.isFastInterruptsDisabled, isTrue);
      expect(isSet(getBit(6, sr.word)), isTrue);

      sr.enableFastInterrupts();
      expect(sr.isFastInterruptsDisabled, isFalse);
      expect(isSet(getBit(6, sr.word)), isFalse);
    });

    test('interrupts should set bit 7.', () {
      expect(sr.isInterruptsDisabled, isFalse);
      expect(isSet(getBit(7, sr.word)), isFalse);

      sr.disableInterrupts();
      expect(sr.isInterruptsDisabled, isTrue);
      expect(isSet(getBit(7, sr.word)), isTrue);

      sr.enableInterrupts();
      expect(sr.isInterruptsDisabled, isFalse);
      expect(isSet(getBit(7, sr.word)), isFalse);
    });
  });
}
