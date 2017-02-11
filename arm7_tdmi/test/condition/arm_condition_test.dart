import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart' hide Func0;

main() {
  String describe(Arm7TdmiPsr cpsr) {
    return {
      'V': cpsr.v ? 1 : 0,
      'C': cpsr.c ? 1 : 0,
      'Z': cpsr.z ? 1 : 0,
      'N': cpsr.n ? 1 : 0,
    }.toString();
  }

  Arm7TdmiPsr cpsr({int v: 0, int c: 0, int z: 0, int n: 0}) =>
      new Arm7TdmiPsr.fromBits()
        ..v = v == 1
        ..c = c == 1
        ..z = z == 1
        ..n = n == 1;

  /// Adds a test case for condition.
  void check(
    Arm7TdmiCondition condition, {
    @required Iterable<Arm7TdmiPsr> success,
    @required Iterable<Arm7TdmiPsr> failure,
  }) {
    group('$Arm7TdmiCondition: $condition', () {
      success.forEach((c) {
        test('should succeed on ${describe(c)}', () {
          expect(condition.passes(c), isTrue);
        });
      });

      failure.forEach((c) {
        test('should fail on ${describe(c)}', () {
          expect(condition.passes(c), isFalse);
        });
      });
    });
  }

  check(
    Arm7TdmiCondition.EQ,
    success: [
      cpsr(z: 1),
    ],
    failure: [
      cpsr(z: 0),
    ],
  );

  check(
    Arm7TdmiCondition.NE,
    success: [
      cpsr(z: 0),
    ],
    failure: [
      cpsr(z: 1),
    ],
  );

  check(
    Arm7TdmiCondition.CS,
    success: [
      cpsr(c: 1),
    ],
    failure: [
      cpsr(c: 0),
    ],
  );

  check(
    Arm7TdmiCondition.CC,
    success: [
      cpsr(c: 0),
    ],
    failure: [
      cpsr(c: 1),
    ],
  );

  check(
    Arm7TdmiCondition.MI,
    success: [
      cpsr(n: 1),
    ],
    failure: [
      cpsr(n: 0),
    ],
  );

  check(
    Arm7TdmiCondition.PL,
    success: [
      cpsr(n: 0),
    ],
    failure: [
      cpsr(n: 1),
    ],
  );

  check(
    Arm7TdmiCondition.VS,
    success: [
      cpsr(v: 1),
    ],
    failure: [
      cpsr(v: 0),
    ],
  );

  check(
    Arm7TdmiCondition.VC,
    success: [
      cpsr(v: 0),
    ],
    failure: [
      cpsr(v: 1),
    ],
  );

  check(
    Arm7TdmiCondition.HI,
    success: [
      cpsr(c: 1, n: 0),
    ],
    failure: [
      cpsr(c: 1, n: 1),
      cpsr(c: 0, n: 0),
    ],
  );

  check(
    Arm7TdmiCondition.LS,
    success: [
      cpsr(c: 0, n: 0),
      cpsr(c: 1, n: 1),
    ],
    failure: [
      cpsr(c: 1, n: 0),
    ],
  );

  check(
    Arm7TdmiCondition.GE,
    success: [
      cpsr(v: 0, n: 0),
      cpsr(v: 1, n: 1),
    ],
    failure: [
      cpsr(v: 1, n: 0),
      cpsr(v: 0, n: 1),
    ],
  );

  check(
    Arm7TdmiCondition.LT,
    success: [
      cpsr(v: 1, n: 0),
      cpsr(v: 0, n: 1),
    ],
    failure: [
      cpsr(v: 0, n: 0),
      cpsr(v: 1, n: 1),
    ],
  );

  check(
    Arm7TdmiCondition.GT,
    success: [
      cpsr(z: 0, v: 0, n: 0),
      cpsr(z: 0, v: 1, n: 1),
    ],
    failure: [
      cpsr(z: 1, v: 0, n: 0),
      cpsr(z: 1, v: 1, n: 1),
      cpsr(z: 0, v: 0, n: 1),
      cpsr(z: 0, v: 1, n: 0),
    ],
  );

  check(
    Arm7TdmiCondition.LE,
    success: [
      cpsr(z: 1, v: 0, n: 0),
      cpsr(z: 1, v: 1, n: 1),
      cpsr(z: 0, v: 0, n: 1),
      cpsr(z: 0, v: 1, n: 0),
    ],
    failure: [
      cpsr(z: 0, v: 0, n: 0),
      cpsr(z: 0, v: 1, n: 1),
    ],
  );

  check(
    Arm7TdmiCondition.AL,
    success: [
      cpsr(v: 1, c: 1, z: 1, n: 1),
      cpsr(v: 0, c: 1, z: 1, n: 1),
      cpsr(v: 1, c: 0, z: 1, n: 1),
      cpsr(v: 1, c: 1, z: 0, n: 1),
      cpsr(v: 1, c: 1, z: 1, n: 0),
      cpsr(v: 0, c: 0, z: 1, n: 1),
      cpsr(v: 1, c: 1, z: 0, n: 0),
      cpsr(v: 1, c: 0, z: 0, n: 0),
      cpsr(v: 0, c: 1, z: 0, n: 0),
      cpsr(v: 0, c: 0, z: 1, n: 0),
      cpsr(v: 0, c: 0, z: 0, n: 1),
      cpsr(v: 0, c: 0, z: 0, n: 0),
    ],
    failure: [],
  );

  check(
    Arm7TdmiCondition.NV,
    success: [],
    failure: [
      cpsr(v: 1, c: 1, z: 1, n: 1),
      cpsr(v: 0, c: 1, z: 1, n: 1),
      cpsr(v: 1, c: 0, z: 1, n: 1),
      cpsr(v: 1, c: 1, z: 0, n: 1),
      cpsr(v: 1, c: 1, z: 1, n: 0),
      cpsr(v: 0, c: 0, z: 1, n: 1),
      cpsr(v: 1, c: 1, z: 0, n: 0),
      cpsr(v: 1, c: 0, z: 0, n: 0),
      cpsr(v: 0, c: 1, z: 0, n: 0),
      cpsr(v: 0, c: 0, z: 1, n: 0),
      cpsr(v: 0, c: 0, z: 0, n: 1),
      cpsr(v: 0, c: 0, z: 0, n: 0),
    ],
  );

  // TODO: Add remaining test cases back for CS -> NV.
}
