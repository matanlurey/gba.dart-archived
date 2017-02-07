import 'dart:math' show pow;

import 'package:binary/binary.dart';
import 'package:test/test.dart';

void main() {
  group('bit', () {
    test('should have a length of 1 and be unsigned', () {
      expect(bit.isSigned, isFalse);
      expect(bit.isUnsigned, isTrue);
      expect(bit.length, 1);
    });

    test('should be able to be 0 or 1', () {
      expect(bit.min, 0);
      expect(bit.max, 1);
      expect(bit.inRange(-1), isFalse);
      expect(bit.inRange(0), isTrue);
      expect(bit.inRange(1), isTrue);
      expect(bit.inRange(2), isFalse);
    });
  });

  group('uint32', () {
    test('should have a length of 32 and be unsigned', () {
      expect(uint32.isSigned, isFalse);
      expect(uint32.isUnsigned, isTrue);
      expect(uint32.length, 32);
    });

    test('should be able to be 0 to 2 ^ 32 - 1', () {
      expect(uint32.min, 0);
      expect(uint32.max, pow(2, 32) - 1);
      expect(uint32.inRange(-1), isFalse);
      expect(uint32.inRange(pow(2, 32) - 1), isTrue);
      expect(uint32.inRange(pow(2, 32)), isFalse);
    });

    test('mask should correctly mask values', () {
      int maxTimes16 = uint32.max << 4;
      expect(uint32.mask(maxTimes16), 0xFFFFFFF0);
    });

    test('add should correctly add values', () {
      expect(uint32.add(0, 0), 0);
      expect(uint32.add(10, 20), 30);
      expect(uint32.add(uint32.max, 1), 0x100000000);
    });

    test('subtract should correctly subtract values', () {
      // Positive operands.
      expect(uint32.subtract(0, 0), 0);
      // 20 - 10 = 10
      expect(uint32.subtract(20, 10), 0xA);

      // One negative operand
      // 10 - -10 = 0xA - 0xFFFFFFF6 = 10 - (2^32 - 10)
      expect(uint32.subtract(10, -10), 10 - (pow(2, 32) - 10));

      // Two negative operands
      // -10 - -10 = 0xFFFFFFF6 - 0xFFFFFFF6 = (2^32 - 10) - (2^32 - 10) = 0
      expect(uint32.subtract(-10, -10), 0);
    });

    test('should be able to iterate through bits', () {
      expect(
        uint32.toIterable(2),
        [
          0,
          1,
        ]..addAll(new Iterable.generate(30, (_) => 0)),
      );
    });
  });

  group('int32', () {
    test('mask should correctly mask values', () {
      int maxTimes16 = int32.max << 4;
      expect(int32.mask(maxTimes16), 0xFFFFFFF0);
    });

    test('add should correctly add values', () {
      // Positive operands
      expect(int32.add(0, 0), 0);
      expect(int32.add(10, 20), 30);
      expect(int32.add(int32.max, 1), 0x80000000);

      // One negative operand
      // -2 + 3 == 1 with carry bit
      expect(int32.add(-2, 3), 0x100000001);
      // -2 + 1 == -1
      expect(int32.add(-2, 1), 0xFFFFFFFF);

      // Two negative operands
      // -1 + -1 == -2 with carry bit
      expect(int32.add(-1, -1), 0x1FFFFFFFE);
    });

    test('subtract should correctly subtract values', () {
      // Positive operands.
      expect(int32.subtract(0, 0), 0);
      // 20 - 10 = 20 + -10 = 0x14 + 0xFFFFFFF6 = 10 with carry bit
      expect(int32.subtract(20, 10), 0x010000000A);

      // One negative operand
      // 10 - -10 = 10 + 10 = 0xA - 0xA = 20
      expect(int32.subtract(10, -10), 0x14);

      // -10 - 10 = 0xFFFFFFF6 - 0xA = -20 with carry bit
      expect(int32.subtract(-10, 10), 0x1FFFFFFEC);

      // Two negative operands
      // -10 - -10 = -10 + 10 = 0xFFFFFFF6 + 0xA = 0 with carry bit
      expect(int32.subtract(-10, -10), 0x100000000);
    });
  });

  // TODO: Add more exhaustive tests and tests for the other data types.
}
