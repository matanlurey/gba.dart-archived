import 'dart:io';
import 'dart:typed_data';

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
  });
}
