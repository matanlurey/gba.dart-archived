import 'dart:typed_data';

import 'package:binary/binary.dart';
import 'package:meta/meta.dart';
import 'package:quiver/time.dart';

/// Built-in RTC (real-time clock) support.
class RealTimeClock {
  static const _timeYear = 0;
  static const _timeMonth = 1;
  static const _timeDay = 2;
  static const _timeDayOfWeek = 3;
  static const _timeHour = 4;
  static const _timeMinute = 5;
  static const _timeSecond = 6;

  static const _totalBytes = const [
    0, // Force reset
    0, // Empty
    7, // Date/Time
    0, // Force IRQ
    1, // Control register
    0, // Empty
    3, // Time
    0, // Empty
  ];

  final Clock _clock;

  @visibleForTesting
  final List<int> time = new Uint8List(7);

  int _bits = 0;
  int _bitsRead = 0;
  int _bytesRemaining = 0;
  int _command = 0;
  int _control = 0x40;
  int _direction = 0;

  // TODO: Remove these fields if they end up being unused.

  // ignore: unused_field
  int _pins = 0;

  // ignore: unused_field
  int _reading = 0;

  // Transfer sequence:
  // == Initiate
  // > HI | - | LO | -
  // > HI | - | HI | -
  // == Transfer bit (x8)
  // > LO | x | HI | -
  // > HI | - | HI | -
  // < ?? | x | ?? | -
  // == Terminate
  // >  - | - | LO | -
  int _transferStep = 0;

  RealTimeClock({
    Clock clock: const Clock(),
  }) : _clock = clock;

  static int _bcd(int binary) {
    var counter = binary % 10;
    binary ~/= 10;
    counter += (binary % 10) << 4;
    return counter;
  }

  /// Sets pins according to [nibble].
  void setPins(int nibble) {
    switch (_transferStep) {
      case 0:
        if (nibble & 5 == 1) {
          _transferStep = 1;
        }
        break;
      case 1:
        if (!isZero(nibble & 4)) {
          _transferStep = 2;
        }
        break;
      case 2:
        if (isZero(nibble & 1)) {
          _bits &= ~(1 << _bitsRead);
          _bits |= ((nibble & 2) >> 1) << _bitsRead;
        } else if (!isZero(nibble & 4)) {
          // SIO direction should always != this.read
          if (!isZero(_direction & 2) && !false/*this.read*/) {
            if (++_bitsRead == 8) {
              processByte();
            } else {
              // outputPins(5 | sioOutputPin() << 1);
              if (++_bitsRead == 8) {
                if (--_bytesRemaining <= 0) {
                  _command = -1;
                }
                _bitsRead = 0;
              }
            }
          }
        } else {
          _bitsRead = 0;
          _bytesRemaining = 0;
          _command = -1;
          _transferStep = 0;
        }
        break;
    }
    _pins = nibble & 7;
  }

  /// Processes a byte.
  void processByte() {
    --_bytesRemaining;
    switch (_command) {
      case -1:
        if (_bits & 0x0F == 0x06) {
          _command = (_bits >> 4) & 7;
          _reading = _bits & 0x80;
          _bytesRemaining = _totalBytes[_command];
          switch (_command) {
            case 0:
              _control = 0;
              break;
            case 2:
            case 6:
              update();
              break;
          }
        } else {
          // TODO: Make this an exception?
          print('Invalid RTC Command Byte: ${_bits.toRadixString(16)}');
        }
        break;
      case 4:
        // Control.
        _control = _bits & 0x40;
        break;
    }
    _bits = 0;
    _bitsRead = 0;
    if (_bytesRemaining == 0) {
      _command = -1;
    }
  }

  /// Returns the output of the pin.
  int sioOutputPin() {
    var output = 0;
    switch (_command) {
      case 4:
        output = _control;
        break;
      case 2:
      case 6:
        output = time[7 - _bytesRemaining];
        break;
    }
    return (output >> _bitsRead) & 1;
  }

  /// Updates the system clock based on the real time.
  void update() {
    final now = _clock.now();
    time
      ..[_timeYear] = _bcd(now.year)
      ..[_timeMonth] = _bcd(now.month)
      ..[_timeDay] = _bcd(now.day)
      ..[_timeDayOfWeek] = _bcd(now.weekday - 1)
      ..[_timeMinute] = _bcd(now.minute)
      ..[_timeSecond] = _bcd(now.second);
    if (!isZero(_control & 0x40)) {
      // 24 Hour.
      time[_timeHour] = _bcd(now.hour);
    } else {
      final hour = _bcd(now.hour % 2);
      time[_timeHour] = hour >= 12 ? hour | 0x80 : hour;
    }
  }
}
