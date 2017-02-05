import 'package:arm7_tdmi/src/cpu/program_status_registers.dart';
import 'package:arm7_tdmi/src/utils/bits.dart';

/// A bit string for determining whether an ARM instruction will execute.
///
/// A [Condition] is derived from bits 31-28 of an ARM instruction.
abstract class Condition {
  static final Condition equal = new _Equal._();
  static final Condition notEqual = new _NotEqual._();
  static final Condition carrySet = new _CarrySet._();
  static final Condition carryClear = new _CarryClear._();
  static final Condition negative = new _Negative._();
  static final Condition positiveOrZero = new _PositiveOrZero._();
  static final Condition overflow = new _Overflow._();
  static final Condition noOverflow = new _NoOverflow._();
  static final Condition unsignedHigher = new _UnsignedHigher._();
  static final Condition unsignedLowerOrSame = new _UnsignedLowerOrSame._();
  static final Condition greaterThanOrEqual = new _GreaterThanOrEqual._();
  static final Condition lessThan = new _LessThan._();
  static final Condition greaterThan = new _GreaterThan._();
  static final Condition lessThanOrEqual = new _LessThanOrEqual._();
  static final Condition always = new _Always._();
  static final Condition unpredictable = new _Unpredictable._();

  static final Map<int, Condition> _valueToCondition = <int, Condition>{
    equal.value: equal,
    notEqual.value: notEqual,
    carrySet.value: carrySet,
    carryClear.value: carryClear,
    negative.value: negative,
    positiveOrZero.value: positiveOrZero,
    overflow.value: overflow,
    noOverflow.value: noOverflow,
    unsignedHigher.value: unsignedHigher,
    unsignedLowerOrSame.value: unsignedLowerOrSame,
    greaterThanOrEqual.value: greaterThanOrEqual,
    lessThan.value: lessThan,
    greaterThan.value: greaterThan,
    lessThanOrEqual.value: lessThanOrEqual,
    always.value: always,
    unpredictable.value: unpredictable,
  };

  /// Returns the [Condition] whose 4-bit string matches [nibble].
  factory Condition.fromBits(int nibble) {
    if (_valueToCondition.containsKey(nibble)) {
      return _valueToCondition[nibble];
    }
    throw new UnsupportedError('condition $nibble');
  }

  /// The value representing this [Condition].
  int get value;

  /// The mnemonic representing this [Condition].
  String get name;

  /// Returns true iff the state of [registers] passes this [Condition].
  bool passes(ProgramStatusRegisters registers);

  @override
  String toString() => name;
}

class _Equal implements Condition {
  const _Equal._();

  @override
  final String name = 'EQ';

  @override
  final int value = 0;

  @override
  bool passes(ProgramStatusRegisters registers) => isSet(registers.zeroFlag);
}

class _NotEqual implements Condition {
  const _NotEqual._();

  @override
  final String name = 'NE';

  @override
  final int value = 1;

  @override
  bool passes(ProgramStatusRegisters registers) => isUnset(registers.zeroFlag);
}

class _CarrySet implements Condition {
  const _CarrySet._();

  @override
  final String name = 'CS';

  @override
  final int value = 2;

  @override
  bool passes(ProgramStatusRegisters registers) => isSet(registers.carryFlag);
}

class _CarryClear implements Condition {
  const _CarryClear._();

  @override
  final String name = 'CC';

  @override
  final int value = 3;

  @override
  bool passes(ProgramStatusRegisters registers) => isUnset(registers.carryFlag);
}

class _Negative implements Condition {
  const _Negative._();

  @override
  final String name = 'MI';

  @override
  final int value = 4;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isSet(registers.negativeFlag);
}

class _PositiveOrZero implements Condition {
  const _PositiveOrZero._();

  @override
  final String name = 'PL';

  @override
  final int value = 5;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isUnset(registers.negativeFlag);
}

class _Overflow implements Condition {
  const _Overflow._();

  @override
  final String name = 'VS';

  @override
  final int value = 6;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isSet(registers.overflowFlag);
}

class _NoOverflow implements Condition {
  const _NoOverflow._();

  @override
  final String name = 'VC';

  @override
  final int value = 7;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isUnset(registers.overflowFlag);
}

class _UnsignedHigher implements Condition {
  const _UnsignedHigher._();

  @override
  final String name = 'HI';

  @override
  final int value = 8;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isSet(registers.carryFlag) && isUnset(registers.zeroFlag);
}

class _UnsignedLowerOrSame implements Condition {
  const _UnsignedLowerOrSame._();

  @override
  final String name = 'LS';

  @override
  final int value = 9;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isUnset(registers.carryFlag) || isSet(registers.zeroFlag);
}

class _GreaterThanOrEqual implements Condition {
  const _GreaterThanOrEqual._();

  @override
  final String name = 'GE';

  @override
  final int value = 10;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      registers.negativeFlag == registers.overflowFlag;
}

class _LessThan implements Condition {
  const _LessThan._();

  @override
  final String name = 'LT';

  @override
  final int value = 11;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      registers.negativeFlag != registers.overflowFlag;
}

class _GreaterThan implements Condition {
  const _GreaterThan._();

  @override
  final String name = 'GT';

  @override
  final int value = 12;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isUnset(registers.zeroFlag) &&
      registers.negativeFlag == registers.overflowFlag;
}

class _LessThanOrEqual implements Condition {
  const _LessThanOrEqual._();

  @override
  final String name = 'LE';

  @override
  final int value = 13;

  @override
  bool passes(ProgramStatusRegisters registers) =>
      isSet(registers.zeroFlag) ||
      registers.negativeFlag != registers.overflowFlag;
}

class _Always implements Condition {
  const _Always._();

  @override
  final String name = 'AL';

  @override
  final int value = 14;

  @override
  bool passes(ProgramStatusRegisters registers) => true;
}

class _Unpredictable implements Condition {
  const _Unpredictable._();

  @override
  final String name = 'UNPREDICTABLE';

  @override
  final int value = 15;

  // It's unclear what this does at the moment.
  @override
  bool passes(ProgramStatusRegisters registers) =>
      throw new UnimplementedError();
}
