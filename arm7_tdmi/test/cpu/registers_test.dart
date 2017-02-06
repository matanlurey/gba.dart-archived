import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:test/test.dart';

main() {
  Arm7TdmiRegisters registers;

  setUp(() {
    registers = new Arm7TdmiRegisters();
  });

  test('should read/write to R0->R7 for every operating mode', () {
    Arm7TdmiOperatingMode.values.forEach((mode) {
      for (var i = 0; i < 8; i++) {
        expect(
          registers.set(i, 1),
          isNot(throwsA(anything)),
          reason: '$mode should be able to write to register R$i',
        );
        expect(
          registers.get(i),
          1,
          reason: '$mode should be able to read from register R$i',
        );
      }
    });
    final data = registers.toFixedList();
    expect(
      data.getRange(0, 7),
      everyElement(1),
      reason: 'Should have written a value of "1" to registers R0-R7',
    );
  });

  // TODO: Add tests for registers R8->R15.
  // TODO: Add tests for the CPSR.
  // TODO: Add tests for the SPSR.
}
