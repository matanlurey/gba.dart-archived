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

  // TODO: Add remaining test cases back for CS -> NV.
}
