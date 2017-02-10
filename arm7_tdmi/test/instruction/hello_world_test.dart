import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/instruction.dart';
import 'package:test/test.dart';

// TODO(kharland): Implement swi to call printf with data stored in register 1
// of length stored in register 2.
void main() {
  test('Should pass hello world test', () {
    final cpu = new Arm7Tdmi(gprs: new Arm7TdmiRegisters());

    final program = [
      // Loads the literal 4 into register 7
      const [MOV, 0x02000000 /* mov1 r7 #4 */],
      // Loads the literal 1 into register 0
      const [MOV, 0x02000000 /* mov1 r0 #1 */],
      // Loads the length of the string to print into register 2
      const [MOV, 0x02000000 /* mov2 r2 helloWorld.length (4) */],
      // Loads the string to print into register 1
      const [LDR, 0x02000000 /* ldr r1 helloWorld */],
      // Software interrupt w/ r0: 1 and r7: 4 == call printf
      const [SWI, 0x0E000010 /* swi 0 */],
      // Loads the literal 1 into register 7
      const [MOV, 0x02000000 /* mov r7, #1 */],
      // Software interrupt w/ r0: 1 and r7: 7 == exit
      const [SWI, 0x0E000010 /* swi 0 */],
    ];

    program.forEach((instructionParts) {
      var bits = instructionParts.last;
      var format = new Arm7TdmiInstructionFormat.decoded(bits);
      var instruction = instructionParts.first as Arm7TdmiInstruction;
      instruction.execute(cpu, format, bits);
    });

    // TODO(kjharland): change to helloWorld after instructions are implemented.
    expect(cpu.gprs.get(0), anything);
  });
}
