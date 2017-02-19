import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:gba/gba.dart';

/// A generic pin on an integrated circuit or computer board.
class GeneralPurposeIO {
  final MemoryAccess _memory;

  // TODO: Support additional devices.
  final RealTimeClock _rtc;

  int _direction = 0;
  int _readWrite = 0;

  GeneralPurposeIO(this._memory, this._rtc);

  void outputPins(int nibble) {
    if (_readWrite != 0) {
      var old = _memory.read16(0xC4);
      old &= _direction;
      _memory.write16(0xC4, old | (nibble & ~_direction & 0xF));
    }
  }

  /// Writes a 16-bit uint [value] to [offset].
  void write16(int offset, int value) {
    switch (offset) {
      case 0xC4:
        _rtc.setPins(value & 0xF);
        break;
      case 0xC6:
        _direction = value & 0xF;
        _rtc.setDirection(_direction);
        break;
      case 0xC8:
        _readWrite = value & 1;
        break;
      default:
        throw 'BUG: Bad offset passed to GPIO: ${offset.toRadixString(16)}';
    }
    if (_readWrite != 0) {
      var old = _memory.read16(offset);
      old &= ~_direction;
      _memory.write16(offset, old | (value & _direction));
    }
  }
}
