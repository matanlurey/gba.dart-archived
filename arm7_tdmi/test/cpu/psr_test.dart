import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';

void main() {
  Arm7TdmiPsr psr;

  setUp(() {
    psr = new Arm7TdmiPsr.fromBits();
  });

  test('should initially be in ARM state', () {
    expect(psr.isArmState, isTrue);
    expect(psr.isThumbState, isFalse);
  });

  test('should flip to THUMB state, then back to ARM', () {
    psr.setStateToThumb();
    expect(psr.isThumbState, isTrue);
    expect(psr.isArmState, isFalse);
    psr.setStateToArm();
    expect(psr.isArmState, isTrue);
    expect(psr.isThumbState, isFalse);
  });

  group('should be able to change/validate operating modes', () {
    Arm7TdmiOperatingMode.values.forEach((mode) {
      test('to $mode', () {
        psr.operatingMode = mode;
        expect(psr.operatingMode, mode, reason: 'Should be $mode');
      });
    });
  });
}
