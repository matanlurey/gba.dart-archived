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

  // TODO: Add more exhaustive tests and tests for the other data types.
}
