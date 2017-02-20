import 'package:binary/binary.dart';
import 'package:func/func.dart';
import 'package:meta/meta.dart';

/// A 16-bit register functioning as the status indicator of the GBA display.
class ScanlineRegister {
  // Reads from memory.
  final Func0<int> _read;

  ScanlineRegister({@required int read()}) : _read = read;

  /// The position of the scanline
  int get lineNumber => bitChunk(_read(), 7, 8);
}