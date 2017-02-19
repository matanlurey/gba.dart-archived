import 'dart:io';
import 'dart:typed_data';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:gba/src/cartridge/header.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  new Directory(p.join('test', 'roms')).listSync().forEach((file) {
    if (file is File) {
      _run(file);
    }
  });
}

void _run(File file) {
  test('should pass ${p.basename(file.path)}', () {
    final rom = file.readAsBytesSync();
    final header = new CartridgeHeaderReader(
      new Uint32List.fromList(rom).buffer,
    );
    final offset = header.entryPoint != 0 ? header.entryPoint : 0x14F;
    final formats = rom
      .skip(offset)
      .map((i) {
        try {
          return new Arm7TdmiInstructionFormat.decoded(i);
        } catch (e) {
          return e.toString();
        }
      })
      .toList();
    for (var i = 0; i < formats.length; i++) {
      print('[${(offset + i).toRadixString(2)}]: ${formats[i]}');
    }
  });
}
