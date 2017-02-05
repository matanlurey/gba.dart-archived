import 'package:arm7_tdmi/src/cpu/operating_modes.dart';
import 'package:test/test.dart';

void main() {
  group('$OperatingMode', () {
    test('isPrivileged should return true only for user mode', () {
      expect(OperatingMode.user.isPrivileged, true);
      expect(OperatingMode.fastInterrupt.isPrivileged, false);
      expect(OperatingMode.interrupt.isPrivileged, false);
      expect(OperatingMode.supervisor.isPrivileged, false);
      expect(OperatingMode.abort.isPrivileged, false);
      expect(OperatingMode.system.isPrivileged, false);
      expect(OperatingMode.undefined.isPrivileged, false);
    });

    test(
        'canAccessSpsr should return true for all modes except user and '
        'system', () {
      expect(OperatingMode.user.canAccessSpsr, false);
      expect(OperatingMode.system.canAccessSpsr, false);
      expect(OperatingMode.fastInterrupt.canAccessSpsr, true);
      expect(OperatingMode.interrupt.canAccessSpsr, true);
      expect(OperatingMode.supervisor.canAccessSpsr, true);
      expect(OperatingMode.abort.canAccessSpsr, true);
      expect(OperatingMode.undefined.canAccessSpsr, true);
    });
  });
}
