import 'package:arm7_tdmi/src/cpu/psr.dart';
import 'package:arm7_tdmi/src/instruction/arm/condition.dart';
import 'package:test/test.dart';

void main() {
  group('$Condition', () {
    StatusRegister sr;

    setUp(() {
      sr = new StatusRegister();
    });

    test(
        "equal.passes should return true iff the given registers' zero flag is "
        "set", () {
      expect(Condition.equal.passes(sr), false);
      sr.setZero();
      expect(Condition.equal.passes(sr), true);
    });

    test(
        "notEqual.passes should return true iff the given registers' zero flag "
        "is unset", () {
      expect(Condition.notEqual.passes(sr), true);
      sr.setZero();
      expect(Condition.notEqual.passes(sr), false);
    });

    test(
        "carrySet.passes should return true iff the given registers' carry "
        "flag is unset", () {
      expect(Condition.carrySet.passes(sr), false);
      sr.enableCarry();
      expect(Condition.carrySet.passes(sr), true);
    });

    test(
        "carryClear.passes should return true iff the given registers' carry "
        "flag is unset", () {
      expect(Condition.carryClear.passes(sr), true);
      sr.enableCarry();
      expect(Condition.carryClear.passes(sr), false);
    });

    test(
        "negative.passes should return true iff the given registers' signed "
        "flag is set", () {
      expect(Condition.negative.passes(sr), false);
      sr.setSigned();
      expect(Condition.negative.passes(sr), true);
    });

    test(
        "positiveOrZero.passes should return true iff the given registers' "
        "signed flag is unset", () {
      expect(Condition.positiveOrZero.passes(sr), true);
      sr.setSigned();
      expect(Condition.positiveOrZero.passes(sr), false);
    });

    test(
        "overflow.passes should return true iff the given registers' overflow"
        "flag is set", () {
      expect(Condition.overflow.passes(sr), false);
      sr.enableOverflow();
      expect(Condition.overflow.passes(sr), true);
    });

    test(
        "noOverflow.passes should return true iff the given registers' "
        "overflow flag is unset", () {
      expect(Condition.noOverflow.passes(sr), true);
      sr.enableOverflow();
      expect(Condition.noOverflow.passes(sr), false);
    });

    test(
        "unsignedHigher.passes should return true iff the given registers' "
        "carry flag is set and zero flag is unset", () {
      sr.enableCarry();
      sr.setZero();
      expect(Condition.unsignedHigher.passes(sr), false);

      sr.disableCarry();
      sr.setNonZero();
      expect(Condition.unsignedHigher.passes(sr), false);

      sr.enableCarry();
      sr.setZero();
      expect(Condition.unsignedHigher.passes(sr), false);

      sr.enableCarry();
      sr.setNonZero();
      expect(Condition.unsignedHigher.passes(sr), true);
    });

    test(
        "unsignedLowerOrSame.passes should return true iff the given "
        "registers' carry flag is unset or the zero flag is set", () {
      sr.enableCarry();
      sr.setZero();
      expect(Condition.unsignedLowerOrSame.passes(sr), true);

      sr.disableCarry();
      sr.setNonZero();
      expect(Condition.unsignedLowerOrSame.passes(sr), true);

      sr.enableCarry();
      sr.setNonZero();
      expect(Condition.unsignedLowerOrSame.passes(sr), false);

      sr.disableCarry();
      sr.setZero();
      expect(Condition.unsignedLowerOrSame.passes(sr), true);
    });

    test(
        "greaterThanOrEqual.passes should return true iff the given "
        "registers' negative and overflow flags are equal", () {
      sr.setUnsigned();
      sr.disableOverflow();
      expect(Condition.greaterThanOrEqual.passes(sr), true);

      sr.setSigned();
      sr.enableOverflow();
      expect(Condition.greaterThanOrEqual.passes(sr), true);

      sr.setSigned();
      sr.disableOverflow();
      expect(Condition.greaterThanOrEqual.passes(sr), false);

      sr.setUnsigned();
      sr.enableOverflow();
      expect(Condition.greaterThanOrEqual.passes(sr), false);
    });

    test(
        "lessThan.passes should return true iff the given registers' negative "
        "and overflow flags are not equal", () {
      sr.setUnsigned();
      sr.disableOverflow();
      expect(Condition.lessThan.passes(sr), false);

      sr.setSigned();
      sr.enableOverflow();
      expect(Condition.lessThan.passes(sr), false);

      sr.setSigned();
      sr.disableOverflow();
      expect(Condition.lessThan.passes(sr), true);

      sr.setUnsigned();
      sr.enableOverflow();
      expect(Condition.lessThan.passes(sr), true);
    });

    test(
        "greaterThan.passes should return true iff the given registers' zero "
        "flag is unset and the negative and overflow flags are equal", () {
      sr.setNonZero();
      sr.setUnsigned();
      sr.disableOverflow();
      expect(Condition.greaterThan.passes(sr), true);

      sr.setSigned();
      sr.enableOverflow();
      expect(Condition.greaterThan.passes(sr), true);

      sr.setSigned();
      sr.disableOverflow();
      expect(Condition.greaterThan.passes(sr), false);

      sr.setUnsigned();
      sr.enableOverflow();
      expect(Condition.greaterThan.passes(sr), false);

      sr.setZero();
      sr.setUnsigned();
      sr.disableOverflow();
      expect(Condition.greaterThan.passes(sr), false);

      sr.setSigned();
      sr.enableOverflow();
      expect(Condition.greaterThan.passes(sr), false);

      sr.setSigned();
      sr.disableOverflow();
      expect(Condition.greaterThan.passes(sr), false);

      sr.setUnsigned();
      sr.enableOverflow();
      expect(Condition.greaterThan.passes(sr), false);
    });

    test(
        "lessThanOrEqual.passes should return true iff the given registers' "
        "negative and overflow flags are not equal or the zero flag is set",
        () {
      sr.setZero();
      sr.setUnsigned();
      sr.disableOverflow();
      expect(Condition.lessThanOrEqual.passes(sr), true);

      sr.setSigned();
      sr.enableOverflow();
      expect(Condition.lessThanOrEqual.passes(sr), true);

      sr.setSigned();
      sr.disableOverflow();
      expect(Condition.lessThanOrEqual.passes(sr), true);

      sr.setUnsigned();
      sr.enableOverflow();
      expect(Condition.lessThanOrEqual.passes(sr), true);

      sr.setNonZero();
      sr.setUnsigned();
      sr.disableOverflow();
      expect(Condition.lessThanOrEqual.passes(sr), false);

      sr.setSigned();
      sr.enableOverflow();
      expect(Condition.lessThanOrEqual.passes(sr), false);

      sr.setSigned();
      sr.disableOverflow();
      expect(Condition.lessThanOrEqual.passes(sr), true);

      sr.setUnsigned();
      sr.enableOverflow();
      expect(Condition.lessThanOrEqual.passes(sr), true);
    });
  });
}
