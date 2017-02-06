import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';

void main() {
  test('isPrivileged should return `true` only for user mode', () {
    expect(Arm7TdmiOperatingMode.usr.isPrivileged, isTrue);
    Arm7TdmiOperatingMode
        .values
        .where((mode) => mode != Arm7TdmiOperatingMode.usr)
        .forEach((mode) {
      expect(
        mode.isPrivileged,
        isFalse,
        reason: '$mode should not be privileged',
      );
    });
  });

  test('canAccessSpsr should return `true` for all modes but user/system', () {
    final noAccess = const [
      Arm7TdmiOperatingMode.usr,
      Arm7TdmiOperatingMode.sys,
    ];
    noAccess.forEach((mode) {
      expect(
        mode.canAccessSpsr,
        isFalse,
        reason: '$mode should not be able to access the SPSR',
      );
    });
    Arm7TdmiOperatingMode.values
        .where((v) => !noAccess.contains(v))
        .forEach((mode) {
      expect(
        mode.canAccessSpsr,
        isTrue,
        reason: '$mode should be able to access the SPSR',
      );
    });
  });
}
