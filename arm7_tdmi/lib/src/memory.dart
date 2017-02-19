import 'dart:typed_data';

import 'package:quiver/core.dart';

/// Allows reading and writing bytes to a memory location.
class Memory implements MemoryAccess {
  final Uint8List _view8;
  final Uint16List _view16;
  final Uint32List _view32;

  /// Create a view into a [buffer] that is used to store memory.
  ///
  /// To create a new block of memory, use the [ByteData] class:
  /// ```
  /// // Creates a new memory view into 1KB of space.
  /// new Memory.view(new ByteData(1024));
  /// ```
  Memory.view(ByteBuffer buffer)
      : _view8 = new Uint8List.view(buffer),
        _view16 = new Uint16List.view(buffer),
        _view32 = new Uint32List.view(buffer);

  @override
  int read8(int address) => _view8[address];

  @override
  int read16(int address) => _view16[address];

  @override
  int read32(int address) => _view32[address];

  @override
  void write8(int address, int value) {
    _view8[address] = value;
  }

  @override
  void write16(int address, int value) {
    _view16[address] = value;
  }

  @override
  void write32(int address, int value) {
    _view32[address] = value;
  }
}

/// Defines a narrow interface for I/O to a specific RAM space.
///
/// See the default implementation, [Memory].
abstract class MemoryAccess {
  /// Reads a 8-bit integer at [address].
  int read8(int address);

  /// Reads a 16-bit integer at [address].
  int read16(int address);

  /// Reads a 32-bit integer at [address].
  int read32(int address);

  /// Writes a 8-bit integer [value] to [address].
  void write8(int address, int value);

  /// Writes a 16-bit integer [value] to [address].
  void write16(int address, int value);

  /// Writes a 32-bit integer [value] to [address].
  void write32(int address, int value);
}

/// Applies a bitwise-and (`&`) operation before reading/writing to an address.
///
/// In systems programming a mask might be applied for different memory
/// locations - it might be used it ignore or otherwise write and read to
/// memory in a specialized way.
class BitwiseAndMemoryMask implements MemoryAccess {
  final MemoryAccess _delegate;
  final int _mask;

  /// Create a new address-based mask delegating to a memory location.
  const BitwiseAndMemoryMask(this._mask, this._delegate);

  @override
  int read8(int address) => _delegate.read8(address & _mask);

  @override
  int read16(int address) => _delegate.read16(address & _mask);

  @override
  int read32(int address) => _delegate.read32(address & _mask);

  @override
  void write8(int address, int value) {
    _delegate.write8(address & _mask, value);
  }

  @override
  void write16(int address, int value) {
    _delegate.write16(address & _mask, value);
  }

  @override
  void write32(int address, int value) {
    _delegate.write32(address & _mask, value);
  }
}

/// Reading or writing to [MemoryAccess] was unsupported.
class MemoryAccessError extends UnsupportedError {
  /// Memory location that access was attempted.
  final int address;

  /// Value attempted to be written, otherwise `null` on a read operation.
  final int value;

  MemoryAccessError.read(int address, [String message])
      : this.address = address,
        this.value = null,
        super(message ?? 'Cannot read from address $address');

  MemoryAccessError.write(int address, int value, [String message])
      : this.address = address,
        this.value = value,
        super(message ?? 'Cannot write value $value to address $address');

  @override
  int get hashCode => hash2(address, value);

  @override
  bool operator ==(Object o) {
    if (o is MemoryAccessError) {
      return o.address == address && o.value == value;
    }
    return false;
  }

  /// Whether this was a read operation.
  bool get isRead => value == null;

  /// Whether this was a write operation.
  bool get isWrite => value != null;
}

/// A mixin or base class that prevents reading from a location in RAM.
///
/// Throws a [MemoryAccessError] when reading is attempted.
abstract class ReadOnlyMemory implements MemoryAccess {
  @override
  int read8(int address) => throw new MemoryAccessError.read(address);

  @override
  int read16(int address) => throw new MemoryAccessError.read(address);

  @override
  int read32(int address) => throw new MemoryAccessError.read(address);
}

/// A mixin or base class that prevents writing to a location in RAM.
///
/// Throws a [MemoryAccessError] when writing is attempted.
abstract class WriteOnlyMemory implements MemoryAccess {
  @override
  void write8(int address, int value) {
    throw new MemoryAccessError.write(address, value);
  }

  @override
  void write16(int address, int value) {
    throw new MemoryAccessError.write(address, value);
  }

  @override
  void write32(int address, int value) {
    throw new MemoryAccessError.write(address, value);
  }
}
