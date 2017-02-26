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

    // TODO: Move this into a decode_rom_test.dart.
    test('should be decodable', () {
      final decoder = const Arm7TdmiDecoder();
      final armBranch = decoder.decodeArmFormat(reader.entryPoint);
      expect(armBranch, const isInstanceOf<Branch>());
      final offset = const Branch().offset(reader.entryPoint);
      final program = new Uint32List.view(
        gbaFileBytes.buffer,
        offset * Uint32List.BYTES_PER_ELEMENT,
      );
      program.forEach((instruction) {
        try {
          final arm = decoder.decodeArm(instruction);
          print(arm.disassemble(instruction));
        } catch (_) {
          final format = decoder.decodeArmFormat(instruction);
          final desc = instruction.toRadixString(2).padLeft(32, '0');
          print('$desc: ??? (${format.runtimeType})');
        }
        expect(() => decoder.decodeArmFormat(instruction), returnsNormally);
      });
    });

    // TODO: Add test to ensure this fails on an invalid logo.
    test('should verify whether a cartridge contains the nintendo logo', () {
      expect(reader.hasValidNintendoLogo, isTrue);
    });

    test('should have some magic byte set', () {
      expect(reader.isValidRom, isTrue);
    });
  });
}
