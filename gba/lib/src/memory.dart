import 'dart:typed_data';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:func/func.dart';
import 'package:meta/meta.dart';

/// Access into all of the RAM for the emulator.
class MemoryManager {
  static const _ramSizeBios = 0x4000;
  static const _ramSizeWork = 0x40000;
  static const _ramSizeInternal = 0x8000;
  static const _ramSizeIO = 0x400;
  static const _ramSizePalette = 0x400;
  static const _ramSizeVideo = 0x20000;
  static const _ramSizeObject = 0x400;

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

  final ByteBuffer _buffer;

  /// Memory location for the BIOS.
  final MemoryAccess bios;

  /// Memory location for internal use.
  final MemoryAccess internal;

  /// Memory location for work.
  final MemoryAccess work;

  /// Create a new empty [MemoryManager] unit for the emulator.
  ///
  /// May optionally specify [isBiosProtected] to conditionally protect [bios].
  factory MemoryManager({
    bool isBiosProtected(),
  }) {
    return new MemoryManager.fromBuffer(
      new Uint8List(_totalRamSize).buffer,
      isBiosProtected: isBiosProtected,
    );
  }

  /// Creates a new [MemoryManager] unit from an existing memory [buffer].
  ///
  /// May optionally specify [isBiosProtected] to conditionally protect [bios].
  factory MemoryManager.fromBuffer(
    ByteBuffer buffer, {
    bool isBiosProtected(),
  }) {
    // Create the views into all available memory with correct lengths/offsets.
    final viewBios = new Uint8List.view(
      buffer,
      0,
      _ramSizeBios,
    );
    final viewInternal = new Uint8List.view(
      buffer,
      _ramSizeBios,
      _ramSizeInternal,
    );
    final viewWork = new Uint8List.view(
      buffer,
      _ramSizeBios + _ramSizeInternal,
      _ramSizeWork,
    );
    // Create memory access interfaces and finalize the memory manager unit.
    return new MemoryManager._(
      buffer,
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
    this._buffer, {
    @required this.bios,
    @required this.internal,
    @required this.work,
  });

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
    bool isProtected() = _noProtection,
  })
      : _isProtected = isProtected,
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
