import 'package:arm7_tdmi/src/cpu/program_status_registers.dart';
import 'package:arm7_tdmi/src/utils/bits.dart';
import 'package:test/test.dart';

void main() {
  group('$ProgramStatusRegisters', () {
    ProgramStatusRegisters registers;

    setUp(() {
      registers = new ProgramStatusRegisters();
    });

    test('negativeFlag should read and write bit 31.', () {
      expect(isSet(registers.negativeFlag), false);
      expect(isSet(getBit(31, registers.dump())), false);

      registers.negativeFlag = 1;
      expect(isSet(registers.negativeFlag), true);
      expect(isSet(getBit(31, registers.dump())), true);

      registers.negativeFlag = 0;
      expect(isSet(registers.negativeFlag), false);
      expect(isSet(getBit(31, registers.dump())), false);
    });

    test('zeroFlag should read and write bit 30', () {
      expect(isSet(registers.zeroFlag), false);
      expect(isSet(getBit(30, registers.dump())), false);

      registers.zeroFlag = 1;
      expect(isSet(registers.zeroFlag), true);
      expect(isSet(getBit(30, registers.dump())), true);

      registers.zeroFlag = 0;
      expect(isSet(registers.zeroFlag), false);
      expect(isSet(getBit(30, registers.dump())), false);
    });

    test('carryFlag should read and write bit 29', () {
      expect(isSet(registers.carryFlag), false);
      expect(isSet(getBit(29, registers.dump())), false);

      registers.carryFlag = 1;
      expect(isSet(registers.carryFlag), true);
      expect(isSet(getBit(29, registers.dump())), true);

      registers.carryFlag = 0;
      expect(isSet(registers.carryFlag), true);
      expect(isSet(getBit(29, registers.dump())), true);
    });

    test('overflowFlag should read and write bit 28', () {
      expect(isSet(registers.overflowFlag), false);
      expect(isSet(getBit(28, registers.dump())), false);

      registers.overflowFlag = 1;
      expect(isSet(registers.overflowFlag), true);
      expect(isSet(getBit(28, registers.dump())), true);

      registers.overflowFlag = 0;
      expect(isSet(registers.overflowFlag), false);
      expect(isSet(getBit(28, registers.dump())), false);
    });

    test('enableIRQInterrupts should set bit 7.', () {
      expect(registers.areIRQInterruptsEnabled, true);
      expect(isSet(getBit(7, registers.dump())), false);

      registers.enableIRQInterrupts();
      expect(registers.areIRQInterruptsEnabled, true);
      expect(isSet(getBit(7, registers.dump())), false);
    });

    test('disableIRQInterrupts should set bit 7.', () {
      expect(registers.areIRQInterruptsEnabled, true);
      expect(isSet(getBit(7, registers.dump())), false);

      registers.disableIRQInterrupts();
      expect(registers.areIRQInterruptsEnabled, false);
      expect(isSet(getBit(7, registers.dump())), true);
    });

    test('enableFIQInterrupts should set bit 6.', () {
      expect(registers.areFIQInterruptsEnabled, true);
      expect(isSet(getBit(6, registers.dump())), false);

      registers.enableFIQInterrupts();
      expect(registers.areFIQInterruptsEnabled, true);
      expect(isSet(getBit(6, registers.dump())), false);
    });

    test('disableFIQInterrupts should set bit 6.', () {
      expect(registers.areFIQInterruptsEnabled, true);
      expect(isSet(getBit(6, registers.dump())), false);

      registers.disableFIQInterrupts();
      expect(registers.areFIQInterruptsEnabled, false);
      expect(isSet(getBit(6, registers.dump())), true);
    });
  });
}
