import 'package:gba/gba.dart';
import 'package:test/test.dart';

main() {
  group('$Emulator', () {
    test('should run and stop', () {
      final emulator = new Emulator();

      expect(emulator.isRunning, isFalse);
      emulator.run();
      expect(emulator.isRunning, isTrue);
      emulator.stop();
      expect(emulator.isRunning, isFalse);
    });
  });
}
