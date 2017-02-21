import 'package:binary/binary.dart';
import 'package:func/func.dart';
import 'package:meta/meta.dart';

class VideoMode {}

/// A 16-bit register functioning as the primary control of the GBA screen.
class DisplayControlRegister {
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

  /// Returns true if the loaded cartridge is a GameBoy Color cartridge.
  bool get isGameBoyColor => isSet(_read(), _bitGB);

  /// Returns the page displayed on the screen.
  ///
  /// Video modes 4 and 5 can use page flipping for smoother animation.
  int get page => getBit(_read(), _bitPS);

  /// Forces a blank screen.
  void forceBlank() {
    _write(setBit(_read(), _bitFB));
  }

  /// Enables rendering background 0.
  void enableBackground0() {
    _write(setBit(_read(), _bitBG0));
  }

  /// Enables rendering background 1.
  void enableBackground1() {
    _write(setBit(_read(), _bitBG1));
  }

  /// Enables rendering background 2.
  void enableBackground2() {
    _write(setBit(_read(), _bitBG2));
  }

  /// Enables rendering background 3.
  void enableBackground3() {
    _write(setBit(_read(), _bitBG3));
  }

  /// Enables rendering.
  void enableObject() {
    _write(setBit(_read(), _bitObj));
  }

  /// Enables window 0.
  void enableWindow0() {
    _write(setBit(_read(), _bitW0));
  }

  /// Enables window 1.
  void enableWindow1() {
    _write(setBit(_read(), _bitW1));
  }

  /// Enables the object window.
  void enableObjectWindow() {
    _write(setBit(_read(), _bitOW));
  }

  // TODO(kharland): implement below.

  /// The current video mode.
  ///
  /// 0, 1, and 2 are tiled modes.  3, 4, and 5 are bitmap modes.
  VideoMode get videoMode => null;

  /// Sets the page displayed on the screen.
  ///
  /// See getter [page] for more information.
  set page(int value) {}
}
