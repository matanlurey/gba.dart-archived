import 'dart:io';
import 'dart:typed_data';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:gba/src/cartridge/header.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('$CartridgeHeaderReader', () {
    CartridgeHeaderReader reader;
    Uint8List gbaFileBytes;

    setUpAll(() {
      final gbaTestFile = new File(path.join(
        'test',
        'data',
        'test.gba',
      ));
      gbaFileBytes = new Uint8List.fromList(
        gbaTestFile.readAsBytesSync(),
      );
      reader = new CartridgeHeaderReader(gbaFileBytes.buffer);
    });

    test('should correctly read a cartridge\'s title', () {
      expect(reader.gameTitle, 'Test');
    });

    test('should output the entrypoint of the program', () {
      expect(reader.entryPoint, 0xEA00002E);
    });

    // TODO: Add test to ensure this fails on an invalid logo.
    test('should verify whether a cartridge contains the nintendo logo', () {
      expect(reader.hasValidNintendoLogo, isTrue);
    });

    test('should have some magic byte set', () {
      expect(reader.isValidRom, isTrue);
    });

    // TODO: Move this to separate test.
    test('should be able to decode some instructions', () {
      // Should recognize this as a branch instruction.
      final entryPoint = reader.entryPoint;
      final format = new Arm7TdmiInstructionFormat.decoded(entryPoint);
      expect(format, const isInstanceOf<Branch>());

      final decoder = const Arm7TdmiDecoder();
      var immediate = const Branch().offset(entryPoint);
      immediate <<= 2;
      print(immediate);

      final actualProgram = new Uint32List.view(
        gbaFileBytes.buffer,
        immediate,
      );
      actualProgram
          .map((i) {
            try {
              return new Arm7TdmiInstructionFormat.decoded(i).runtimeType;
            } catch (_) {
              return '--- ERROR ---: $i';
            }
          })
          .where((i) => i != null)
          .forEach(print);
    });
  });
}
