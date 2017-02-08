import 'dart:math';
import 'dart:typed_data';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';

main() {
  void readAndWrite(
    List<int> createBacking(),
    MemoryAccess createMemory(ByteBuffer buffer),
  ) {
    List<int> backing;
    MemoryAccess memory;

    setUp(() {
      backing = createBacking();
      memory = createMemory((backing as TypedData).buffer);
    });

    test('should read 8 bits', () {
      backing[0] = 255;
      expect(memory.read8(0), 255);
    });

    test('should read 16 bits', () {
      backing[0] = 255;
      expect(memory.read16(0), 255);
    });

    test('should read 32 bits', () {
      backing[0] = 255;
      expect(memory.read32(0), 255);
    });

    test('should write 8 bits', () {
      memory.write8(0, 255);
      expect(backing[0], 255);
    });

    test('should write 16 bits', () {
      memory.write16(0, 255);
      expect(backing[0], 255);
    });

    test('should write 32 bits', () {
      memory.write32(0, 255);
      expect(backing[0], 255);
    });
  }

  group('$Memory', () {
    readAndWrite(
      () => new Uint8List(32),
      (ByteBuffer buffer) => new Memory.view(buffer),
    );
  });

  group('$BitwiseAndMemoryMask', () {
    readAndWrite(
      () => new Uint8List(32),
      (buffer) => new BitwiseAndMemoryMask(0x00003FFF, new Memory.view(buffer)),
    );
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
