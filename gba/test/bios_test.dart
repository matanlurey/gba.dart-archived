import 'package:gba/gba.dart';
import 'package:test/test.dart';

void main() {
  test('should load the BIOS', () async {
    final mmu = new MemoryManager();
    expect(mmu.bios.read8(0), 0);
    await mmu.loadBios();
    final first8Bytes = const [0x06, 0x00, 0x00, 0xEA, 0xFE, 0xFF, 0XFF, 0xEA];
    for (var i = 0; i < first8Bytes.length; i++) {
      expect(mmu.bios.read8(i), first8Bytes[i]);
    }
  });
}
