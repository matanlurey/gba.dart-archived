/// A library for common bit operations.
///
/// Every function in this library treats 32-bit strings as little-endian:
/// leftmost bit is 31, rightmost bit is 0.
import 'package:binary/binary.dart';

final maxSignedInt32 = int32.max;
final minSignedInt32 = int32.min;

/// Whether [bit] is set to 1
bool isSet(int bit) => bit == 1;

/// Whether [bit] is set to 0.
bool isUnset(int bit) => !isSet(bit);

/// Get the [i]th bit from [bits].
int getBit(int i, int bits) {
  assert(i >= 0 && i <= 31);
  return bits >> i & 1;
}

/// If the [i]th bit of [bits] is set, returns an integer identical to [bits].
/// Otherwise returns an integer identical to [bits] but with the [i]th bit set.
int setBit(int i, int bits) {
  assert(i <= 31 && i >= 0);
  return bits | (1 << i);
}

/// If the [i]th bit of [bits] is unset, returns an integer identical to [bits].
/// Otherwise returns an integer identical to [bits] but without the [i]th bit
/// set.
int unsetBit(int i, int bits) {
  assert(i <= 31 && i >= 0);
  return bits & ~(1 << i);
}

/// Returns an integer containing the bits in the range
/// [[leftBit],[leftBit] + [size]] from the word [bits], left-padded with 0's.
int getBitChunk(int leftBit, int size, int bits) {
  assert(size >= 0 && size <= 31);
  assert(leftBit >= 0 && leftBit <= 31);
  return (bits >> (leftBit + 1 - size)) & ~(~0 << size);
}

/// Returns an integer containing bits [left] to [right] inclusive from [bits].
/// The result is, left-padded with 0's.
int getBitRange(int left, int right, int bits) =>
    getBitChunk(left, left - right + 1, bits);

/// Returns 1 iff [op1] + [op2] + [op3] is greater than [int32.max], else 0.
int carryFrom(int result) => result > int32.max ? 1 : 0;

/// Returns 0 if [number] is non-negative, else 1.
int sign(int number) => getBit(31, number);

/// Returns 1 iff [op1] + [op2] + [op3] produces an integer overflow, else 0.
int overflowFromAdd(int op1, int op2, int result) =>
    sign(op1) == sign(op2) && sign(result) != sign(op1) ? 1 : 0;

/// Returns 1 iff [op1] - [op2] produces a 32-bit signed overflow, else 0.
int overflowFromSub(int op1, int op2, int result) =>
    sign(op1) != sign(op2) && sign(result) != sign(op1) ? 1 : 0;
