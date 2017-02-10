/// A struct-like object representing a read-only memory location.
class MemoryLocation {
  /// The number of bytes before this memory location.
  final int offset;

  /// The length of this location in bytes.
  final int length;

  const MemoryLocation(this.offset, this.length);
}
