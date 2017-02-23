import 'dart:async';
import 'dart:typed_data';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:func/func.dart';
import 'package:meta/meta.dart';
import 'package:resource/resource.dart';

/// Function signature for a function that asynchronously loads a BIOS.
typedef Future<List<int>> BiosLoader();

/// Access into all of the RAM for the emulator.
class MemoryManager {
  /// Total size of GBA memory map, including unused areas (except the last).
  static const numAddresses = 0x0fffffff;

  static Future<List<int>> _loadBiosDefault() {
    return const Resource('package:gba/bios.bin').readAsBytes();
  }

  final BiosLoader _biosLoader;

  final ByteBuffer _buffer;

  /// Memory location for the BIOS.
  ///
  /// Executable functions to enable faster development.
  final MemoryAccess bios;

  /// Memory location for internal use.
  ///
  /// This memory is embedded in the CPU and it's the fastest memory section.
  /// The 32bit bus means that ARM instructions can be loaded at once. This is
  /// available for code and data.
  final MemoryAccess internalWork;

  /// Memory location for work.
  ///
  /// Can be used for code and data.
  final MemoryAccess externalWork;

  /// Video RAM.
  ///
  /// This is where the data used for backgrounds and sprites are stored. The
  /// interpretation of this data depends on a number of things, including video
  /// mode and background and sprite settings.
  final MemoryAccess video;

  /// Memory-mapped IO registers.
  ///
  /// Used to control graphics, sound, buttons and other features.
  final MemoryAccess io;

  /// Memory for two palettes containing 256 entries of 15-bit colors each.
  ///
  /// The first is for backgrounds, the second for sprites.
  final MemoryAccess palette;

  /// Object Attribute Memory.
  ///
  /// This is where sprites are controlled.
  final MemoryAccess object;

  /// Create a new empty [MemoryManager] unit for the emulator.
  ///
  /// May optionally specify [isBiosProtected] to conditionally protect [bios].
  factory MemoryManager({
    BiosLoader biosLoader: _loadBiosDefault,
    bool isBiosProtected(),
  }) {
    return new MemoryManager.fromBuffer(
      new Uint8List(numAddresses).buffer,
      biosLoader: biosLoader,
      isBiosProtected: isBiosProtected,
    );
  }

  /// Creates a new [MemoryManager] unit from an existing memory [buffer].
  ///
  /// May optionally specify [isBiosProtected] to conditionally protect [bios].
  factory MemoryManager.fromBuffer(
    ByteBuffer buffer, {
    BiosLoader biosLoader: _loadBiosDefault,
    bool isBiosProtected(),
  }) {
    MemoryAccess createMemoryView(
      ByteBuffer buffer,
      MemoryBlock block,
    ) =>
        new BitwiseAndMemoryMask(
            block.end,
            new Memory.view(
                new Uint8List.view(buffer, block.start, block.end).buffer));

    final bios = biosBlock(buffer);

    // Create memory access interfaces and finalize the memory manager unit.
    return new MemoryManager._(buffer, biosLoader,
        // BIOS: Masked, and has a special protection protocol.
        bios: new BitwiseAndMemoryMask(
          bios.end,
          new _ProtectedMemory.view(
            bios.bytes.buffer,
            isProtected: isBiosProtected,
          ),
        ),
        internalWork: createMemoryView(buffer, internalWorkBlock(buffer)),
        externalWork: createMemoryView(buffer, externalWorkBlock(buffer)),
        io: createMemoryView(buffer, ioBlock(buffer)),
        palette: createMemoryView(buffer, paletteBlock(buffer)),
        video: createMemoryView(buffer, videoBlock(buffer)),
        object: createMemoryView(buffer, objectBlock(buffer)));
  }

  MemoryManager._(
    this._buffer,
    this._biosLoader, {
    @required this.bios,
    @required this.internalWork,
    @required this.externalWork,
    @required this.io,
    @required this.palette,
    @required this.video,
    @required this.object,
  });

  /// Loads the BIOS returning a future that completes when done.
  Future<Null> loadBios() async {
    var block = biosBlock(_buffer);
    _buffer
        .asUint8List(block.start, block.lengthInBytes)
        .setAll(0, await _biosLoader());
  }

  /// Returns a *copy* of all memory as a buffer, perhaps for serialization.
  Uint8List toFixedList() => new Uint8List.fromList(_buffer.asUint8List());
}

/// A specialized memory location.
///
/// It is illegal to write to this RAM area (read-only).
///
/// It is illegal to read from this RAM area when protection is enabled. For
/// example, a BIOS will run reading a memory location, and once done will
/// enable protection to avoid applications reading from it.
class _ProtectedMemory extends Memory with UnwriteableMemory {
  static bool _noProtection() => false;

  final Func0<bool> _isProtected;

  /// Creates a write-protected memory location into [buffer].
  ///
  /// May optionally define an [isProtected] function that can be used to
  /// conditionally enable or disable reading from this location as well.
  _ProtectedMemory.view(
    ByteBuffer buffer, {
    bool isProtected(),
  })
      : _isProtected = isProtected ?? _noProtection,
        super.view(buffer);

  @override
  int read8(int address) {
    if (_isProtected()) {
      throw new MemoryAccessError.read(address, 'Read protection is enabled');
    }
    return super.read8(address);
  }

  @override
  int read16(int address) {
    if (_isProtected()) {
      throw new MemoryAccessError.read(address, 'Read protection is enabled');
    }
    return super.read16(address);
  }

  @override
  int read32(int address) {
    if (_isProtected()) {
      throw new MemoryAccessError.read(address, 'Read protection is enabled');
    }
    return super.read32(address);
  }
}

/* General internal memory blocks */

/// The [MemoryBlock] representing the bios.
///
/// This block is is 16kb.
MemoryBlock biosBlock(ByteBuffer b) => new MemoryBlock(
      b,
      0x0,
      0x3fff,
    );

/// The [MemoryBlock] representing the internal or 'on-board' working memory.
///
/// This block is 256kb.
MemoryBlock internalWorkBlock(ByteBuffer b) => new MemoryBlock(
      b,
      0x2000000,
      0x203ffff,
    );

/// The [MemoryBlock] representing external or 'on-chip' memory.
///
/// This block is 32kb.
MemoryBlock externalWorkBlock(ByteBuffer b) => new MemoryBlock(
      b,
      0x3000000,
      0x3007fff,
    );

/// The [MemoryBlock] representing io memory.
///
/// This block is 1kb.
MemoryBlock ioBlock(ByteBuffer b) => new MemoryBlock(
      b,
      0x4000000,
      0x40003fe,
    );

/* Internal display memory blocks */

/// The [MemoryBlock] representing palette memory.
///
/// This block is 1kb.
MemoryBlock paletteBlock(ByteBuffer b) => new MemoryBlock(
      b,
      0x5000000,
      0x50003ff,
    );

/// The [MemoryBlock] representing video memory.
///
/// This block is 96kb.
MemoryBlock videoBlock(ByteBuffer b) => new MemoryBlock(
      b,
      0x6000000,
      0x6017fff,
    );

/// The [MemoryBlock] representing object access memory.
///
/// This block is 1kb.
MemoryBlock objectBlock(ByteBuffer b) => new MemoryBlock(
      b,
      0x7000000,
      0x70003ff,
    );

/* External memory (Game Pak) Omitted for now */

/// A specific, contiguous block of memory.
class MemoryBlock {
  /// The low address of this block.
  final int start;

  /// The high address of this block.
  final int end;
  final Uint8List _bytes;

  MemoryBlock(ByteBuffer buffer, this.start, this.end)
      : _bytes = buffer.asUint8List(start, end - start);

  /// The bytes between this block's [start] and [end] addresses.
  Uint8List get bytes => _bytes;

  /// The number of bytes in this block.
  int get lengthInBytes => _bytes.lengthInBytes;
}
