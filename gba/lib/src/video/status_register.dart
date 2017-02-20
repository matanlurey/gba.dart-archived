import 'package:binary/binary.dart';
import 'package:func/func.dart';
import 'package:meta/meta.dart';

/// A 16-bit register functioning as the status indicator of the GBA display.
class DisplayStatusRegister {
  static const _bitVbS = 0;
  static const _bitHbS = 1;
  static const _bitVcS = 2;
  static const _bitVbI = 3;
  static const _bitHbI = 4;
  static const _bitVcI = 5;

  // Reads from memory.
  final Func0<int> _read;

  DisplayStatusRegister({@required int read()}) : _read = read;

  /// Whether the display is in the vblank phase.
  ///
  /// The vblank phase takes place after the vdraw phase and involves writing 68
  /// 68 blank scanlines in the memory regions outside the maximum vertical
  /// display range.
  bool get isVBlank => isSet(_bitVbS, _read());

  /// Whether the display is in the hblank phase.
  ///
  /// The hblank phase takes place after the hdraw phase and involves writing 68
  /// 68 blank columns in the memory regions outside the maximum horizontal
  /// display range.
  bool get isHBlank => isSet(_bitHbS, _read());

  /// Whether the current scanline matches the the scanline trigger.
  bool get isVCountTrigger => isSet(_bitVcS, _read());

  /// Whether an interrupt will be fired at vblank.
  bool get isVBlankInterruptRequestSet => isSet(_bitVbI, _read());

  /// Whether an interrupt will be fired at hblank.
  bool get isHBlankInterruptRequestSet => isSet(_bitHbI, _read());

  /// Whether an interrupt will be fired at when [isVCountTrigger] becomes true.
  bool get isVCountInterruptRequestSet => isSet(_bitVcI, _read());

  /// VCount trigger value.
  ///
  /// If the current scanline is at this value, bit 2 is set and an interrupt
  /// request is fired.
  int get vCountTrigger => bitChunk(_read(), 0xF, 8);
}
