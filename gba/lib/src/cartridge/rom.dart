import 'package:gba/src/memory_location.dart';

/// An interface for read-only memory.
abstract class Rom {
  /// Returns the bytes at the give [memoryLocation].
  ///
  /// The returned bytes are left-padded with zeroes.
  List<int> read(MemoryLocation memoryLocation);
}

