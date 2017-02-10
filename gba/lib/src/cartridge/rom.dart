/// An interface for read-only memory.
abstract class Rom {
  /// Returns [numBytes] bytes starting at [address].
  ///
  /// The returned bytes are left-padded with zeroes.
  List<int> read(int address, int numBytes);
}

