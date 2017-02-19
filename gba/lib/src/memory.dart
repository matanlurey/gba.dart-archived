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
  static Future<List<int>> _loadBiosDefault() {
    return const Resource('package:gba/bios.bin').readAsBytes();
  }

  // 16kb.
  static const _ramSizeBios = 0x4000;

  // 256kb.
  static const _ramSizeWork = 0x40000;

  // 32kb.
  static const _ramSizeInternal = 0x8000;

  // 1kb.
  static const _ramSizeIO = 0x400;

  // 1kb.
  static const _ramSizePalette = 0x400;

  // 96kb.
  static const _ramSizeVideo = 0x20000;

  // 1kb.
  static const _ramSizeObject = 0x400;

  static const _offsetBios = 0;
  static const _offsetInternal = _ramSizeBios;
  static const _offsetWork = _offsetInternal + _ramSizeInternal;

  static const _maskBios = 0x00003FFF;
  static const _maskWork = 0x0003FFFF;
  static const _maskInternal = 0x00007FFF;

  static const _totalRamSize = _ramSizeBios +
      _ramSizeWork +
      _ramSizeInternal +
      _ramSizeIO +
      _ramSizePalette +
      _ramSizeVideo +
      _ramSizeObject;

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
  final MemoryAccess internal;

  /// Memory location for work.
  ///
  /// Can be used for code and data.
  final MemoryAccess work;

  /// Memory-mapped IO registers.
  ///
  /// Used to control graphics, sound, buttons and other features.
  MemoryAccess get io => throw new UnimplementedError();

  /// Memory for two palettes containing 256 entries of 15-bit colors each.
  ///
  /// The first is for backgrounds, the second for sprites.
  MemoryAccess get palette => throw new UnimplementedError();

  /// Video RAM.
  ///
  /// This is where the data used for backgrounds and sprites are stored. The
  /// interpretation of this data depends on a number of things, including video
  /// mode and background and sprite settings.
  MemoryAccess get video => throw new UnimplementedError();

  /// Object Attribute Memory.
  ///
  /// This is where sprites are controlled.
  MemoryAccess get object => throw new UnimplementedError();

  /// Create a new empty [MemoryManager] unit for the emulator.
  ///
  /// May optionally specify [isBiosProtected] to conditionally protect [bios].
  factory MemoryManager({
    BiosLoader biosLoader: _loadBiosDefault,
    bool isBiosProtected(),
  }) {
    return new MemoryManager.fromBuffer(
      new Uint8List(_totalRamSize).buffer,
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
    // Create the views into all available memory with correct lengths/offsets.
    final viewBios = new Uint8List.view(
      buffer,
      _offsetBios,
      _ramSizeBios,
    );
    final viewInternal = new Uint8List.view(
      buffer,
      _offsetInternal,
      _ramSizeInternal,
    );
    final viewWork = new Uint8List.view(
      buffer,
      _offsetWork,
      _ramSizeWork,
    );
    // Create memory access interfaces and finalize the memory manager unit.
    return new MemoryManager._(
      buffer,
      biosLoader,
      // BIOS: Masked, and has a special protection protocol.
      bios: new BitwiseAndMemoryMask(
        _maskBios,
        new _ProtectedMemory.view(
          viewBios.buffer,
          isProtected: isBiosProtected,
        ),
      ),
      // Internal: Masked.
      internal: new BitwiseAndMemoryMask(
        _maskInternal,
        new Memory.view(viewInternal.buffer),
      ),
      // Working: Masked.
      work: new BitwiseAndMemoryMask(
        _maskWork,
        new Memory.view(viewWork.buffer),
      ),
    );
  }

  MemoryManager._(
    this._buffer,
    this._biosLoader, {
    @required this.bios,
    @required this.internal,
    @required this.work,
  });

  /// Loads the BIOS returning a future that completes when done.
  Future<Null> loadBios() async {
    _buffer
        .asUint8List(_offsetBios, _ramSizeBios)
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
