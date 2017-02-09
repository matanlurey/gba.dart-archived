import 'dart:math' show pow;

import 'package:binary/binary.dart';
import 'package:test/test.dart';

void main() {
  test('bitRange', () {
    expect(bitRange(0x01020304, 31, 24), 0x01);
  });

  test('fromBits', () {
    expect(
      fromBits(const [
        1,
        0,
        0,
        0,
        0,
      ]),
      0x10,
    );
  });

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

    test('carryFrom should return 1 iff the given operands produce a carry',
        () {
      expect(int32.hasCarryBit(int32.max + int32.max), true);
      expect(int32.hasCarryBit(0 + int32.max), false);
      expect(int32.hasCarryBit(1 + int32.max), true);
      expect(int32.hasCarryBit(1 + 2), false);
    });

    test('overflowFromAdd should return 1 iff an addition produces an overflow',
        () {
      expect(int32.doesAddOverflow(int32.max, 0, int32.max), false);
      expect(int32.doesAddOverflow(int32.max, 1, int32.max + 1), true);
      expect(int32.doesAddOverflow(-1, 2, -1 + 2), false);
      expect(int32.doesAddOverflow(0, 2 * int32.max, 0 + 2 * int32.max), false);
    });

    test(
        'overflowFromSub should return 1 iff a subtraction produces an '
        'overflow', () {
      expect(int32.doesSubOverflow(int32.min, 0, int32.min - 0), false);
      expect(int32.doesSubOverflow(int32.min, 1, int32.min - 1), true);
      expect(int32.doesSubOverflow(1, 2, 1 - 2), false);
      expect(int32.doesSubOverflow(0, 2 * int32.max, 0 - 2 * int32.max), false);
    });
  });

  // TODO: Add more exhaustive tests and tests for the other data types.
}
