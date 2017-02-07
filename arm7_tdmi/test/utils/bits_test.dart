import 'package:arm7_tdmi/src/utils/bits.dart';
import 'package:test/test.dart';
import 'dart:math';

void main() {
  group('bits', () {
    test('isSet should return true iff the given bit is set', () {
      expect(isSet(1), true);
      expect(isSet(0), false);
    });

    test('isUnset should return true iff the given bit is set', () {
      expect(isUnset(1), false);
      expect(isUnset(0), true);
    });

    test('getBit should return the ith bit from a bit string', () {
      var nibble = 0xD;
      expect(getBit(0, nibble), 1);
      expect(getBit(1, nibble), 0);
      expect(getBit(2, nibble), 1);
      expect(getBit(3, nibble), 1);
    });

    test('setBit should set the ith bit in a bit string', () {
      var nibble = 0x0;
      expect(setBit(0, nibble), 1);
      expect(setBit(1, nibble), 2);
      expect(setBit(3, setBit(1, nibble)), 10);
    });

    test('unsetBit should unset the ith bit in a bit string', () {
      var nibble = 0xF;
      expect(unsetBit(0, nibble), 14);
      expect(unsetBit(1, nibble), 13);
      expect(unsetBit(3, unsetBit(1, nibble)), 5);
    });

    test(
        'getBitChunk should return the correct left-padded bit-chunk from a '
        'bit string', () {
      var word = 0x01020304;
      expect(getBitChunk(31, 8, word), 0x01);
      expect(getBitChunk(23, 8, word), 0x02);
      expect(getBitChunk(15, 8, word), 0x03);
      expect(getBitChunk(7, 8, word), 0x04);
    });

    test(
        'getBitRange should return the correct left-padded bit-chunk from a '
        'bit string', () {
      var word = 0x01020304;
      expect(getBitRange(31, 24, word), 0x01);
      expect(getBitRange(23, 16, word), 0x02);
      expect(getBitRange(15, 8, word), 0x03);
      expect(getBitRange(7, 0, word), 0x04);
    });

    test('sign should return the 31st bit of the givnen number', () {
      expect(sign(0x80000000), 1);
      expect(sign(0x40000000), 0);
    });

    test('carryFrom should return 1 iff the given operands produce a carry',
        () {
      expect(carryFrom(maxSignedInt32 + maxSignedInt32), 1);
      expect(carryFrom(pow(2, 15) + pow(2, 15)), 0);
      expect(carryFrom(pow(2, 15) + pow(2, 15) - 1), 0);
      expect(carryFrom(1), 0);
      expect(carryFrom(0), 0);
    });

    test('overflowFromAdd should return 1 iff an addition produces an overflow',
        () {
      expect(overflowFromAdd(1, 2, 3), 0);
      expect(overflowFromAdd(-1, 2, 1), 0);
      expect(overflowFromAdd(maxSignedInt32, 0, maxSignedInt32), 0);
      expect(overflowFromAdd(maxSignedInt32, 1, maxSignedInt32 + 1), 1);
      expect(overflowFromAdd(maxSignedInt32, 10, maxSignedInt32 + 10), 1);
    });

    test(
        'overflowFromSub should return 1 iff a subtraction produces an '
        'overflow', () {
      expect(overflowFromSub(1, 2, 3), 0);
      expect(overflowFromSub(-1, 2, 1), 1);
      expect(overflowFromSub(minSignedInt32, 0, minSignedInt32), 0);
      expect(overflowFromSub(minSignedInt32, 1, minSignedInt32 - 1), 1);
      expect(overflowFromSub(minSignedInt32, 10, maxSignedInt32 - 10), 1);
    });
  });
}
