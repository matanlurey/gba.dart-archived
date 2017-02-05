import 'package:arm7_tdmi/src/cpu/psr.dart';
import 'package:arm7_tdmi/src/utils/bits.dart';

/// A bit string for determining whether an ARM instruction will execute.
///
/// A [Condition] is derived from bits 31-28 of an ARM instruction.
abstract class Condition {
  static const Condition equal = const _Equal();
  static const Condition notEqual = const _NotEqual();
  static const Condition carrySet = const _CarrySet();
  static const Condition carryClear = const _CarryClear();
  static const Condition negative = const _Negative();
  static const Condition positiveOrZero = const _PositiveOrZero();
  static const Condition overflow = const _Overflow();
  static const Condition noOverflow = const _NoOverflow();
  static const Condition unsignedHigher = const _UnsignedHigher();
  static const Condition unsignedLowerOrSame = const _UnsignedLowerOrSame();
  static const Condition greaterThanOrEqual = const _GreaterThanOrEqual();
  static const Condition lessThan = const _LessThan();
  static const Condition greaterThan = const _GreaterThan();
  static const Condition lessThanOrEqual = const _LessThanOrEqual();
  static const Condition always = const _Always();
  static const Condition reserved = const _Reserved();

  static final _valueToCondition = new Map<int, Condition>.fromIterable(const [
    equal,
    notEqual,
    carrySet,
    carryClear,
    negative,
    positiveOrZero,
    overflow,
    noOverflow,
    unsignedHigher,
    unsignedLowerOrSame,
    greaterThanOrEqual,
    lessThan,
    greaterThan,
    lessThanOrEqual,
    always,
    reserved,
  ], key: (condition) => condition.value);

  /// Returns the [Condition] whose 4-bit string matches [nibble].
  factory Condition.fromBits(int nibble) {
    final condition = _valueToCondition[nibble];
    if (condition == null) {
      throw new UnsupportedError('Condition $nibble.');
    }
    return condition;
  }

  /// The value representing this [Condition].
  int get value;

  /// The mnemonic representing this [Condition].
  String get name;

  /// Meaning of this condition.
  String get description;

  /// Returns true iff the state of [registers] passes this [Condition].
  bool passes(ProgramStatusRegisters registers);

  @override
  String toString() => name;
}

class _Equal implements Condition {
  const _Equal();

  @override
  final String name = 'EQ';

  @override
  final String description = 'equal (zero) (same)';

  @override
  final int value = 0;

  @override
  bool passes(ProgramStatusRegisters registers) => isSet(registers.zeroFlag);
}

class _NotEqual implements Condition {
  const _NotEqual();

  @override
  final String name = 'NE';

  @override
  final String description = 'not equal (nonzero) (not same)';

  @override
  final int value = 1;

  @override
  bool passes(ProgramStatusRegisters registers) => isUnset(registers.zeroFlag);
}

class _CarrySet implements Condition {
  const _CarrySet();

  @override
  final String name = 'CS';

  @override
  final String description = 'unsigned higher or same (carry set)';

  @override
  final int value = 2;

  @override
  bool passes(ProgramStatusRegisters registers) => isSet(registers.carryFlag);
}

class _CarryClear implements Condition {
  const _CarryClear();

  @override
  final String name = 'CC';

  @override
  final String description = 'unsigned lower (carry cleared)';

  @override
  final int value = 3;

  @override
  bool passes(ProgramStatusRegisters registers) => isUnset(registers.carryFlag);
}

class _Negative implements Condition {
  const _Negative();

  @override
  final String name = 'MI';

  @override
  final String description = 'negative (minus)';

  @override
  final int value = 4;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isSet(registers.negativeFlag);
}

class _PositiveOrZero implements Condition {
  const _PositiveOrZero();

  @override
  final String name = 'PL';

  @override
  final String description = 'positive or zero (plus)';

  @override
  final int value = 5;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isUnset(registers.negativeFlag);
}

class _Overflow implements Condition {
  const _Overflow();

  @override
  final String name = 'VS';

  @override
  final String description = 'overflow (V set)';

  @override
  final int value = 6;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isSet(registers.overflowFlag);
}

class _NoOverflow implements Condition {
  const _NoOverflow();

  @override
  final String name = 'VC';

  @override
  final String description = 'no overflow (V cleared)';

  @override
  final int value = 7;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isUnset(registers.overflowFlag);
}

class _UnsignedHigher implements Condition {
  const _UnsignedHigher();

  @override
  final String name = 'HI';

  @override
  final String description = 'unsigned higher';

  @override
  final int value = 8;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isSet(registers.carryFlag) && isUnset(registers.zeroFlag);
}

class _UnsignedLowerOrSame implements Condition {
  const _UnsignedLowerOrSame();

  @override
  final String name = 'LS';

  @override
  final String description = 'unsigned lower or same';

  @override
  final int value = 9;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isUnset(registers.carryFlag) || isSet(registers.zeroFlag);
}

class _GreaterThanOrEqual implements Condition {
  const _GreaterThanOrEqual();

  @override
  final String name = 'GE';

  @override
  final String description = 'greater or equal';

  @override
  final int value = 0xA;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      registers.negativeFlag == registers.overflowFlag;
}

class _LessThan implements Condition {
  const _LessThan();

  @override
  final String name = 'LT';

  @override
  final String description = 'less than';

  @override
  final int value = 0xB;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      registers.negativeFlag != registers.overflowFlag;
}

class _GreaterThan implements Condition {
  const _GreaterThan();

  @override
  final String name = 'GT';

  @override
  final String description = 'greater than';

  @override
  final int value = 0xC;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isUnset(registers.zeroFlag) &&
      registers.negativeFlag == registers.overflowFlag;
}

class _LessThanOrEqual implements Condition {
  const _LessThanOrEqual();

  @override
  final String name = 'LE';

  @override
  final String description = 'less or equal';

  @override
  final int value = 0xD;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isSet(registers.zeroFlag) ||
      registers.negativeFlag != registers.overflowFlag;
}

class _Always implements Condition {
  const _Always();

  @override
  final String name = 'AL';

  @override
  final String description = 'always (the "AL" suffix can be omitted)';

  @override
  final int value = 0xE;

  @override
  bool passes(ProgramStatusRegisters registers) => true;
}

class _Reserved implements Condition {
  const _Reserved();

  @override
  String get name => throw new UnsupportedError('ARMv1, v2 only');

  @override
  final String description = 'equal (zero) (same)';

  @override
  final int value = 0xF;

  @override
  bool passes(_) => throw new UnsupportedError('ARMv1, v2 only');
}
