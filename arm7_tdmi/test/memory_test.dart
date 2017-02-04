import 'dart:typed_data';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';

main() {
  group('$Memory', () {
    Uint8List backing;
    MemoryAccess memory;

    setUp(() {
      backing = new Uint8List(32);
      memory = new Memory.view(backing.buffer);
    });

    test('should read 8 bits', () {
      backing[0] = 2 ^ 8;
      expect(memory.read8(0), 2 ^ 8);
    });

    test('should read 16 bits', () {
      backing[0] = 2 ^ 16;
      expect(memory.read16(0), 2 ^ 16);
    });

    test('should read 32 bits', () {
      backing[0] = 2 ^ 32;
      expect(memory.read32(0), 2 ^ 32);
    });

    test('should write 8 bits', () {
      memory.write8(0, 2 ^ 8);
      expect(backing[0], 2 ^ 8);
    });

    test('should write 16 bits', () {
      memory.write16(0, 2 ^ 16);
      expect(backing[0], 2 ^ 16);
    });

    test('should write 32 bits', () {
      memory.write32(0, 2 ^ 32);
      expect(backing[0], 2 ^ 32);
    });
  });

  group('$BitwiseAndMemoryMask', () {
    Uint8List backing;
    MemoryAccess memory;

    setUp(() {
      backing = new Uint8List(32);
      memory = new BitwiseAndMemoryMask(
        0x00003FFF,
        new Memory.view(backing.buffer),
      );
    });

    test('should read 8 bits', () {
      backing[0] = 2 ^ 8;
      expect(memory.read8(0), 2 ^ 8);
    });

    test('should read 16 bits', () {
      backing[0] = 2 ^ 16;
      expect(memory.read16(0), 2 ^ 16);
    });

    test('should read 32 bits', () {
      backing[0] = 2 ^ 32;
      expect(memory.read32(0), 2 ^ 32);
    });

    test('should write 8 bits', () {
      memory.write8(0, 2 ^ 8);
      expect(backing[0], 2 ^ 8);
    });

    test('should write 16 bits', () {
      memory.write16(0, 2 ^ 16);
      expect(backing[0], 2 ^ 16);
    });

    test('should write 32 bits', () {
      memory.write32(0, 2 ^ 32);
      expect(backing[0], 2 ^ 32);
    });
  });

  group('$UnwriteableMemory', () {
    UnwriteableMemory memory;

    setUp(() => memory = new _NoWriteMemoryAccess());

    test('should prevent write8', () {
      expect(
        () => memory.write8(0, 0),
        throwsA(new MemoryAccessError.write(0, 0)),
      );
    });

    test('should prevent write16', () {
      expect(
        () => memory.write16(0, 0),
        throwsA(new MemoryAccessError.write(0, 0)),
      );
    });

    test('should prevent write32', () {
      expect(
        () => memory.write32(0, 0),
        throwsA(new MemoryAccessError.write(0, 0)),
      );
    });
  });

  group('$UnreadableMemory', () {
    UnreadableMemory memory;

    setUp(() => memory = new _NoReadMemoryAccess());

    test('should prevent read8', () {
      expect(
        () => memory.read8(0),
        throwsA(new MemoryAccessError.read(0)),
      );
    });

    test('should prevent read16', () {
      expect(
        () => memory.read16(0),
        throwsA(new MemoryAccessError.read(0)),
      );
    });

    test('should prevent read32', () {
      expect(
        () => memory.read32(0),
        throwsA(new MemoryAccessError.read(0)),
      );
    });
  });
}

class _NoReadMemoryAccess extends UnreadableMemory {
  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}

class _NoWriteMemoryAccess extends UnwriteableMemory {
  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
