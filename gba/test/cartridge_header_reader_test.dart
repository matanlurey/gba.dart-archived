import 'dart:typed_data';

import 'package:gba/src/cartridge/catridge_header_reader.dart';
import 'package:resource/resource.dart';
import 'package:test/test.dart';

void main() {
  group('$CartridgeHeaderReader', () {
    CartridgeHeaderReader reader;

    setUp(() async {
      final gbaFileBytes = new Uint8List.fromList(
          await new Resource('package:gba/src/test_data/test.gba')
              .readAsBytes());
      reader = new CartridgeHeaderReader(gbaFileBytes.buffer);
    });

    test("should correctly read a cartridge's title", () {
      expect(reader.gameTitle, 'Test');
    });

    test('should verify whether a cartridge contains the nintendo logo', () {
      expect(reader.hasValidNintendoLogo, isTrue);
      // TODO(kharland): Add test to ensure this fails on an invalid logo.
    });
  });
}
