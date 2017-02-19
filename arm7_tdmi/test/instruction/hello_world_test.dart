import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/instruction.dart';
import 'package:func/func.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

// An example of a platform service that implements `printf`.
class _HelloWorldService implements Arm7TdmiService {
  final VoidFunc1<String> printf;

  const _HelloWorldService({@required this.printf});

  @override
  void call(Arm7Tdmi cpu) {
    final r0 = cpu.gprs.get(0);
    final r7 = cpu.gprs.get(7);
    if (r0 == 1 && r7 == 4) {
      final data = cpu.gprs.get(1).toString();
      final length = cpu.gprs.get(2);
      printf(data.substring(0, length));
      return;
    }
    if (r0 == 1 && r7 == 1) {
      // Exit.
      return;
    }
    throw new UnsupportedError(
      'No matching service call: r[0] = ${r0}, r[7] = ${r7}',
    );
  }
}

void main() {
  test('should run a simple "Hello World" (print 3110)', () {
    final printfLog = <String>[];
    final service = new _HelloWorldService(printf: printfLog.add);
    final cpu = new Arm7Tdmi(gprs: new Arm7TdmiRegisters(), service: service);

    final program = <VoidFunc1<Arm7Tdmi>>[
      // Loads the literal 4 into register 7
      //                mov1 r7 #4
      (Arm7Tdmi cpu) => MOV.execute(gprs: cpu.gprs, rd: 7, shifterOperand: 4),
      // Loads the literal 1 into register 0
      //                mov1 r0 #1
      (Arm7Tdmi cpu) => MOV.execute(gprs: cpu.gprs, rd: 0, shifterOperand: 1),
      // Loads the length of the string to print into register 2
      //                mov2 r2 3110.length (4)
      (Arm7Tdmi cpu) => MOV.execute(gprs: cpu.gprs, rd: 2, shifterOperand: 4),
      // Loads the string to print into register 1
      //                ldr r1 helloWorld
      (Arm7Tdmi cpu) {
        // TODO: Remove once LDR implemented.
        cpu.gprs.set(1, 3110);
      },
      // Software interrupt w/ r0: 1 and r7: 4 == call printf
      //                swi 0
      (Arm7Tdmi cpu) => SWI.execute(cpu: cpu),
      // Loads the literal 1 into register 7
      //                mov r7, #1
      (Arm7Tdmi cpu) => MOV.execute(gprs: cpu.gprs, rd: 7, shifterOperand: 1),
      // Software interrupt w/ r0: 1 and r7: 1 == exit
      //                swi 0
      (Arm7Tdmi cpu) => SWI.execute(cpu: cpu),
    ];

    program.forEach((run) => run(cpu));
    expect(printfLog, ['3110']);
  });
}
