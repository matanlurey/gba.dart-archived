import 'package:arm7_tdmi/src/cpu/psr.dart';
import 'package:arm7_tdmi/src/instruction/arm/condition.dart';
import 'package:test/test.dart';

void main() {
  group('$Condition', () {
    ProgramStatusRegisters registers;

    setUp(() {
      registers = new ProgramStatusRegisters();
    });

    test(
        "equal.passes should return true iff the given registers' zero flag is "
        "set", () {
      expect(Condition.equal.passes(registers), false);
      registers.zeroFlag = 1;
      expect(Condition.equal.passes(registers), true);
    });

    test(
        "notEqual.passes should return true iff the given registers' zero flag "
        "is unset", () {
      expect(Condition.notEqual.passes(registers), true);
      registers.zeroFlag = 1;
      expect(Condition.notEqual.passes(registers), false);
    });

    test(
        "carrySet.passes should return true iff the given registers' carry "
        "flag is unset", () {
      expect(Condition.carrySet.passes(registers), false);
      registers.carryFlag = 1;
      expect(Condition.carrySet.passes(registers), true);
    });

    test(
        "carryClear.passes should return true iff the given registers' carry "
        "flag is unset", () {
      expect(Condition.carryClear.passes(registers), true);
      registers.carryFlag = 1;
      expect(Condition.carryClear.passes(registers), false);
    });

    test(
        "negative.passes should return true iff the given registers' negative "
        "flag is set", () {
      expect(Condition.negative.passes(registers), false);
      registers.negativeFlag = 1;
      expect(Condition.negative.passes(registers), true);
    });

    test(
        "positiveOrZero.passes should return true iff the given registers' "
        "negative flag is unset", () {
      expect(Condition.positiveOrZero.passes(registers), true);
      registers.negativeFlag = 1;
      expect(Condition.positiveOrZero.passes(registers), false);
    });

    test(
        "overflow.passes should return true iff the given registers' overflow"
        "flag is set", () {
      expect(Condition.overflow.passes(registers), false);
      registers.overflowFlag = 1;
      expect(Condition.overflow.passes(registers), true);
    });

    test(
        "noOverflow.passes should return true iff the given registers' "
        "overflow flag is unset", () {
      expect(Condition.noOverflow.passes(registers), true);
      registers.overflowFlag = 1;
      expect(Condition.noOverflow.passes(registers), false);
    });

    test(
        "unsignedHigher.passes should return true iff the given registers' "
        "carry flag is set and zero flag is unset", () {
      registers.carryFlag = 0;
      registers.zeroFlag = 0;
      expect(Condition.unsignedHigher.passes(registers), false);

      registers.carryFlag = 0;
      registers.zeroFlag = 1;
      expect(Condition.unsignedHigher.passes(registers), false);

      registers.carryFlag = 1;
      registers.zeroFlag = 1;
      expect(Condition.unsignedHigher.passes(registers), false);

      registers.carryFlag = 1;
      registers.zeroFlag = 0;
      expect(Condition.unsignedHigher.passes(registers), true);
    });

    test(
        "unsignedLowerOrSame.passes should return true iff the given "
        "registers' carry flag is unset or the zero flag is set", () {
      registers.carryFlag = 0;
      registers.zeroFlag = 0;
      expect(Condition.unsignedLowerOrSame.passes(registers), true);

      registers.carryFlag = 1;
      registers.zeroFlag = 1;
      expect(Condition.unsignedLowerOrSame.passes(registers), true);

      registers.carryFlag = 1;
      registers.zeroFlag = 0;
      expect(Condition.unsignedLowerOrSame.passes(registers), false);

      registers.carryFlag = 0;
      registers.zeroFlag = 1;
      expect(Condition.unsignedLowerOrSame.passes(registers), true);
    });

    test(
        "greaterThanOrEqual.passes should return true iff the given "
        "registers' negative and overflow flags are equal", () {
      registers.negativeFlag = 0;
      registers.overflowFlag = 0;
      expect(Condition.greaterThanOrEqual.passes(registers), true);

      registers.negativeFlag = 1;
      registers.overflowFlag = 1;
      expect(Condition.greaterThanOrEqual.passes(registers), true);

      registers.negativeFlag = 1;
      registers.overflowFlag = 0;
      expect(Condition.greaterThanOrEqual.passes(registers), false);

      registers.negativeFlag = 0;
      registers.overflowFlag = 1;
      expect(Condition.greaterThanOrEqual.passes(registers), false);
    });

    test(
        "lessThan.passes should return true iff the given registers' negative "
        "and overflow flags are not equal", () {
      registers.negativeFlag = 0;
      registers.overflowFlag = 0;
      expect(Condition.lessThan.passes(registers), false);

      registers.negativeFlag = 1;
      registers.overflowFlag = 1;
      expect(Condition.lessThan.passes(registers), false);

      registers.negativeFlag = 1;
      registers.overflowFlag = 0;
      expect(Condition.lessThan.passes(registers), true);

      registers.negativeFlag = 0;
      registers.overflowFlag = 1;
      expect(Condition.lessThan.passes(registers), true);
    });

    test(
        "greaterThan.passes should return true iff the given registers' zero "
        "flag is unset and the negative and overflow flags are equal", () {
      registers.zeroFlag = 0;
      registers.negativeFlag = 0;
      registers.overflowFlag = 0;
      expect(Condition.greaterThan.passes(registers), true);

      registers.negativeFlag = 1;
      registers.overflowFlag = 1;
      expect(Condition.greaterThan.passes(registers), true);

      registers.negativeFlag = 1;
      registers.overflowFlag = 0;
      expect(Condition.greaterThan.passes(registers), false);

      registers.negativeFlag = 0;
      registers.overflowFlag = 1;
      expect(Condition.greaterThan.passes(registers), false);

      registers.zeroFlag = 1;
      registers.negativeFlag = 0;
      registers.overflowFlag = 0;
      expect(Condition.greaterThan.passes(registers), false);

      registers.negativeFlag = 1;
      registers.overflowFlag = 1;
      expect(Condition.greaterThan.passes(registers), false);

      registers.negativeFlag = 1;
      registers.overflowFlag = 0;
      expect(Condition.greaterThan.passes(registers), false);

      registers.negativeFlag = 0;
      registers.overflowFlag = 1;
      expect(Condition.greaterThan.passes(registers), false);
    });

    test(
        "lessThanOrEqual.passes should return true iff the given registers' "
        "negative and overflow flags are not equal or the zero flag is set",
        () {
      registers.zeroFlag = 1;
      registers.negativeFlag = 0;
      registers.overflowFlag = 0;
      expect(Condition.lessThanOrEqual.passes(registers), true);

      registers.negativeFlag = 1;
      registers.overflowFlag = 1;
      expect(Condition.lessThanOrEqual.passes(registers), true);

      registers.negativeFlag = 1;
      registers.overflowFlag = 0;
      expect(Condition.lessThanOrEqual.passes(registers), true);

      registers.negativeFlag = 0;
      registers.overflowFlag = 1;
      expect(Condition.lessThanOrEqual.passes(registers), true);

      registers.zeroFlag = 0;
      registers.negativeFlag = 0;
      registers.overflowFlag = 0;
      expect(Condition.lessThanOrEqual.passes(registers), false);

      registers.negativeFlag = 1;
      registers.overflowFlag = 1;
      expect(Condition.lessThanOrEqual.passes(registers), false);

      registers.negativeFlag = 1;
      registers.overflowFlag = 0;
      expect(Condition.lessThanOrEqual.passes(registers), true);

      registers.negativeFlag = 0;
      registers.overflowFlag = 1;
      expect(Condition.lessThanOrEqual.passes(registers), true);
    });
  });
}
