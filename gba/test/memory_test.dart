import 'dart:typed_data';
import 'package:gba/gba.dart';
import 'package:gba/src/memory.dart';
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

  group('top-level $MemoryBlock creator', () {
    final memory = new Uint8List.fromList(
        new List.generate(MemoryManager.numAddresses, (address) => address));

    [
      [0x00000000, 0x00003fff, biosBlock, 'biosBlock'],
      [0x02000000, 0x0203ffff, internalWorkBlock, 'internalWorkBlock'],
      [0x03000000, 0x03007fff, externalWorkBlock, 'externalWorkBlock'],
      [0x04000000, 0x040003fe, ioBlock, 'ioBlock'],
      [0x05000000, 0x050003ff, paletteBlock, 'paletteBlock'],
      [0x06000000, 0x06017fff, videoBlock, 'videoBlock'],
      [0x07000000, 0x070003ff, objectBlock, 'objectBlock']
    ].forEach((List blockTestingInfo) {
      final start = blockTestingInfo[0];
      final end = blockTestingInfo[1];
      final createBlock = blockTestingInfo[2];
      final name = blockTestingInfo[3];
      final block = createBlock(memory.buffer);

      test(
          '$name should return a $MemoryBlock containing the correct addresses',
          () {
        expect(block.start, start);
        expect(block.end, end);

        // Verify the creator is correctly using its own start and end
        // properties to compute its memory view.
        expect(block.bytes, memory.getRange(start, end), reason: name);
      });
    });
  });
}
