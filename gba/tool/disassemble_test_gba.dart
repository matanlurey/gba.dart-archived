import 'dart:io';
import 'dart:typed_data';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:gba/src/cartridge/header.dart';
import 'package:path/path.dart' as path;

/// Generates test/data/test.gba-disassembled.
void main() {
  final gbaTestFile = new File(path.join(
    'test',
    'data',
    'test.gba',
  ));

  final gbaFileBytes = new Uint8List.fromList(
    gbaTestFile.readAsBytesSync(),
  );

  final decoder = const Arm7TdmiDecoder();
  final reader = new CartridgeHeaderReader(gbaFileBytes.buffer);
  final offset = const Branch().offset(reader.entryPoint);
  final program = new Uint32List.view(
    gbaFileBytes.buffer,
    offset * Uint32List.BYTES_PER_ELEMENT,
  );

  final outputFile = new File(path.join(
    'test',
    'data',
    'test.gba-disassembled',
  ));

  final outSink = outputFile.openWrite();
  program.forEach((instruction) {
    try {
      final arm = decoder.decodeArm(instruction);
      outSink.writeln(arm.disassemble(instruction));
    } catch (_) {
      final format = decoder.decodeArmFormat(instruction);
      final desc = instruction.toRadixString(2).padLeft(32, '0');
      outSink.writeln('$desc: ??? (${format.runtimeType})');
    }
  });
}
