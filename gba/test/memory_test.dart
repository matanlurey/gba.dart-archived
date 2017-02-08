import 'package:gba/gba.dart';
import 'package:test/test.dart';

final throwsMemoryAccessError = throwsA(
  const isInstanceOf<MemoryAccessError>(),
);

main() {
  group('$MemoryManager', () {
    MemoryManager memory;
    var protectBios = false;

    setUp(() {
      memory = new MemoryManager(isBiosProtected: () => protectBios);
    });

    test('should prevent writing to the BIOS', () {
      expect(
        () => memory.bios.write8(0, 0),
        throwsMemoryAccessError,
      );
      expect(
        () => memory.bios.write16(0, 0),
        throwsMemoryAccessError,
      );
      expect(
        () => memory.bios.write32(0, 0),
        throwsMemoryAccessError,
      );
    });

    test('should prevent reading from the BIOS when protection enabled', () {
      expect(
        memory.bios.read8(0),
        isNotNull,
      );
      expect(
        memory.bios.read16(0),
        isNotNull,
      );
      expect(
        memory.bios.read32(0),
        isNotNull,
      );
      protectBios = true;
      expect(
        () => memory.bios.read8(0),
        throwsMemoryAccessError,
      );
      expect(
        () => memory.bios.read16(0),
        throwsMemoryAccessError,
      );
      expect(
        () => memory.bios.read32(0),
        throwsMemoryAccessError,
      );
    });
  });
}
