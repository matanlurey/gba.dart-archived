import 'package:binary/binary.dart';
import 'package:func/func.dart';
import 'package:meta/meta.dart';

class VideoMode {}

/// A 16-bit register functioning as the primary control of the GBA screen.
abstract class DisplayControlRegister {
  static const _bitGB = 3;
  static const _bitPS = 4;
  static const _bitFB = 7;
  static const _bitBG0 = 8;
  static const _bitBG1 = 9;
  static const _bitBG2 = 0xA;
  static const _bitBG3 = 0xB;
  static const _bitObj = 0xC;
  static const _bitW0 = 0xD;
  static const _bitW1 = 0xE;
  static const _bitOW = 0xF;

  // Reads from memory.
  final Func0<int> _read;

  // Writes to memory.
  final VoidFunc1<int> _write;

  DisplayControlRegister({
    @required int read(),
    @required void write(int value),
  })
      : _read = read,
        _write = write;

  /// The current video mode.
  ///
  /// 0, 1, and 2 are tiled modes.  3, 4, and 5 are bitmap modes.
  VideoMode get videoMode;

  /// Returns true if the loaded cartridge is a GameBoy Color cartridge.
  bool get isGameBoyColor => isSet(_bitGB, _read());

  /// Returns the page displayed on the screen.
  ///
  /// Video modes 4 and 5 can use page flipping for smoother animation.
  int get page => getBit(_bitPS, _read());

  // TODO(kharland): implement below.

  /// Sets the page displayed on the screen.
  ///
  /// See getter [page] for more information.
  set page(int value);

  /// Forces a blank screen.
  void forceBlank() {
    _write(setBit(_bitFB, _read()));
  }

  /// Enables rendering background 0.
  void enableBackground0() {
    _write(setBit(_bitBG0, _read()));
  }

  /// Enables rendering background 1.
  void enableBackground1() {
    _write(setBit(_bitBG1, _read()));
  }

  /// Enables rendering background 2.
  void enableBackground2() {
    _write(setBit(_bitBG2, _read()));
  }

  /// Enables rendering background 3.
  void enableBackground3() {
    _write(setBit(_bitBG3, _read()));
  }

  /// Enables rendering.
  void enableObject() {
    _write(setBit(_bitObj, _read()));
  }

  /// Enables window 0.
  void enableWindow0() {
    _write(setBit(_bitW0, _read()));
  }

  /// Enables window 1.
  void enableWindow1() {
    _write(setBit(_bitW1, _read()));
  }

  /// Enables the object window.
  void enableObjectWindow() {
    _write(setBit(_bitOW, _read()));
  }
}
