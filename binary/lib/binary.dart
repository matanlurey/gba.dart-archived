/// Utilities for common binary and bit operations.
///
/// **NOTE**: Every function in this library (unless labeled otherwise) treats
/// 32-bit strings as little-endian: the leftmost bit is 31, rightmost bit is 0.
library binary;

import 'dart:collection' show IterableBase;
import 'dart:math' show pow;

import 'package:meta/meta.dart';

/// Returns the [n]th from [bits].
///
/// There is no range checking in this top-level function. To verify you are
/// accessing a valid bit in _checked_ mode use [Integral.get], for example:
/// ```
/// int8.get(bits, n);
/// ```
int getBit(int bits, int n) => bits >> n & 1;

/// Returns an integer with the [n]th bit in [bits] set.
///
/// There is no range checking in this top-level function. To verify you are
/// accessing a valid bit in _checked_ mode use [Integral.set], for example:
/// ```
/// int8.set(bits, n);
/// ```
int setBit(int bits, int n) => bits | (1 << n);

/// Returns an integer with the [n]th bit in [bits] cleared.
///
/// There is no range checking in this top-level function. To verify you are
/// accessing a valid bit in _checked_ mode use [Integral.clear], for example:
/// ```
/// int8.clear(bits, n);
/// ```
int clearBit(int bits, int n) => bits & ~(1 << n);

/// Returns an int containing bits in [left] to [left] + [size] from [bits].
///
/// The result is left-padded with 0's.
///
/// There is no range checking in this top-level function. To verify you are
/// accessing a valid bit in _checked_ mode use [Integral.chunk], for example:
/// ```
/// int8.chunk(bits, left, size);
/// ```
int bitChunk(int bits, int left, int size) {
  return (bits >> (left + 1 - size)) & ~(~0 << size);
}

/// Returns an int containing bits in [left] to [right] inclusive from [bits].
///
/// The result is left-padded with 0's.
///
/// There is no range checking in this top-level function. To verify you are
/// accessing a valid bit in _checked_ mode use [Integral.range], for example:
/// ```
/// int8.range(bits, left, size);
/// ```
int bitRange(int bits, int left, int right) {
  return bitChunk(bits, left, left - right + 1);
}

/// Base class for common integral data types.
class Integral implements Comparable<Integral> {
  /// All _signed_ data types.
  static const List<Integral> signed = const <Integral>[
    int4,
    int8,
    int16,
    int32,
    int64,
    int128,
  ];

  /// All _unsigned_ data types.
  static const List<Integral> unsigned = const <Integral>[
    bit,
    uint4,
    uint8,
    uint16,
    uint32,
    uint64,
    uint128,
  ];

  /// Number of bits in this data type.
  final int length;

  /// Whether this data type supports negative integers.
  final bool isSigned;

  /// Creates an integral data type of [length].
  @literal
  const Integral._(this.length) : isSigned = true;

  /// Creates an unsigned integral data type of [length].
  @literal
  const Integral._unsigned(this.length) : isSigned = false;

  RangeError _rangeError(int value, [String name]) {
    return new RangeError.range(value, min, max, name);
  }

  /// Whether this data type is not signed (0 or positive integers only).
  bool get isUnsigned => !isSigned;

  /// Returns the [n]th from [bits].
  ///
  /// In _checked mode_, throws if [bits] or [n] not [inRange].
  int get(int bits, int n) {
    _assertInRange(bits, 'bits');
    _assertInRange(n, 'n');
    return getBit(bits, n);
  }

  /// Returns the result of setting the [n]th from [bits].
  ///
  /// In _checked mode_, throws if [bits] or [n] not [inRange].
  int set(int bits, int n) {
    _assertInRange(bits, 'bits');
    _assertInRange(n, 'n');
    return setBit(bits, n);
  }

  /// Returns the result of clearing the [n]th from [bits].
  ///
  /// In _checked mode_, throws if [bits] or [n] not [inRange].
  int clear(int bits, int n) {
    _assertInRange(bits, 'bits');
    _assertInRange(n, 'n');
    return clearBit(bits, n);
  }

  /// Returns an int containing bits in [left] to [left] + [size] from [bits].
  ///
  /// The result is left-padded with 0's.
  int chunk(int bits, int left, int size) {
    _assertInRange(bits, 'bits');
    _assertInRange(left, 'left');
    _assertInRange(size, 'size');
    return bitChunk(bits, left, size);
  }

  /// Returns an int containing bits in [left] to [right] inclusive from [bits].
  ///
  /// The result is left-padded with 0's.
  int range(int bits, int left, int right) {
    return bitRange(bits, left, right);
  }

  @override
  int compareTo(Integral other) => length.compareTo(other.length);

  void _assertInRange(int value, [String name]) {
    assert(() {
      if (!inRange(value)) {
        throw _rangeError(value, name);
      }
      return true;
    });
  }

  /// Whether [value] falls in the range of representable by this data type.
  bool inRange(int value) => value >= min && value <= max;

  /// Minimum value representable by this data type.
  int get min => isSigned ? (-pow(2, length - 1)) : 0;

  /// Maximum value representable by this data type.
  int get max => isSigned ? pow(2, length - 1) - 1 : pow(2, length) - 1;

  /// Returns [bits] as a binary string representation.
  ///
  /// In _checked mode_, throws if [bits] not [inRange].
  String toBinary(int bits) {
    _assertInRange(bits);
    return bits.toRadixString(2);
  }

  /// Returns [bits] as a binary string representation, padded with `0`'s.
  ///
  /// In _checked_ mode, throws if [bits] not [inRange].
  String toBinaryPadded(int bits) {
    _assertInRange(bits);
    return bits.toRadixString(2).padLeft(length, '0');
  }

  /// Returns an iterable over [bits].
  Iterable<int> toIterable(int bits) => new _IterableBits(this, bits);

  @override
  String toString() => '#$Integral {${isSigned ? '' : 'u'}$length}';
}

class _Bit extends Integral {
  const _Bit() : super._unsigned(1);

  @override
  final int min = 0;

  @override
  final int max = 1;
}

class _BitIterator implements Iterator<int> {
  final Integral _type;

  int _bits;
  int _position = -1;

  _BitIterator(this._type, this._bits);

  @override
  int get current => _type.get(_bits, _position);

  @override
  bool moveNext() => ++_position < _type.length;
}

class _IterableBits extends IterableBase<int> {
  final Integral _type;
  final int _bits;

  const _IterableBits(this._type, this._bits);

  @override
  Iterator<int> get iterator => new _BitIterator(_type, _bits);
}

/// A single (unsigned) bit.
const Integral bit = const _Bit();

/// A (signed) 4-bit aggregation.
///
/// Also known as a signed _nibble_, _half-octet_, _semioctet_, _half-byte_.
///
/// Commonly used to represent:
/// * Binary-coded decimal
/// * Single decimal digits
const Integral int4 = const Integral._(4);

/// An unsigned 4-bit aggregation.
///
/// Also known as an unsigned _nibble_, _half-octet_, _semioctet_, _half-byte_.
///
/// Commonly used to represent:
/// * Binary-coded decimal
/// * Single decimal digits
const Integral uint4 = const Integral._unsigned(4);

/// A (signed) 8-bit aggregation.
///
/// Also known as an _octet_, _byte_.
///
/// Commonly used to represent:
/// * ASCII characters
const Integral int8 = const Integral._(8);

/// An unsigned 8-bit aggregation.
///
/// Also known as an _octet_, _byte_.
///
/// Commonly used to represent:
/// * ASCII characters
const Integral uint8 = const Integral._unsigned(8);

/// A (signed) 16-bit aggregation.
///
/// Also known as a _short_.
///
/// Commonly used to represent:
/// * UCS-2 characters
const Integral int16 = const Integral._(16);

/// An unsigned 16-bit aggregation.
///
/// Also known a _short_.
///
/// Commonly used to represent:
/// * UCS-2 characters
const Integral uint16 = const Integral._unsigned(16);

/// A (signed) 32-bit aggregation.
///
/// Also known as a _word_, _long_.
///
/// Commonly used to represent:
/// * UTF-32 characters
/// * True color with alpha
/// * Pointers in 32-bit computing
const Integral int32 = const Integral._(32);

/// An unsigned 32-bit aggregation.
///
/// Also known as a _word_, _long_.
///
/// Commonly used to represent:
/// * UTF-32 characters
/// * True color with alpha
/// * Pointers in 32-bit computing
const Integral uint32 = const Integral._unsigned(32);

/// A (signed) 64-bit aggregation.
///
/// Also known as a _double word_, _long long_.
///
/// Commonly used to represent:
/// * Time (milliseconds since the Unix epoch)
/// * Pointers in 64-bit computing
const Integral int64 = const Integral._(64);

/// An unsigned 64-bit aggregation.
///
/// Also known as a _double word_, _long long_.
///
/// Commonly used to represent:
/// * Time (milliseconds since the Unix epoch)
/// * Pointers in 64-bit computing
const Integral uint64 = const Integral._unsigned(64);

/// A (signed) 128-bit aggregation.
///
/// Also known as a _octa word_.
///
/// Commonly used to represent:
/// * Complicated scientific calculations
/// * IPv6 addresses GUIDs
const Integral int128 = const Integral._(64);

/// An unsigned 128-bit aggregation.
///
/// Also known as a _octa word_.
///
/// Commonly used to represent:
/// * Complicated scientific calculations
/// * IPv6 addresses GUIDs
const Integral uint128 = const Integral._unsigned(64);
