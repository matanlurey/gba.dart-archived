import 'package:arm7_tdmi/arm7_tdmi.dart';

/// An abstraction/strategy for creating an [Arm7TdmiProgram].
abstract class Arm7TdmiCompiler {
  const factory Arm7TdmiCompiler({
    Arm7TdmiDecoder decoder,
  }) = _Arm7TdmiInterpreter;

  /// Create a runnable program by compile/processing [instructions].
  Arm7TdmiProgram compile(Arm7Tdmi cpu, Iterable<int> instructions);
}

class _Arm7TdmiInterpreter implements Arm7TdmiCompiler {
  final Arm7TdmiDecoder _decoder;

  const _Arm7TdmiInterpreter({
    Arm7TdmiDecoder decoder: const Arm7TdmiDecoder(),
  })
      : _decoder = decoder;

  @override
  Arm7TdmiProgram compile(Arm7Tdmi cpu, Iterable<int> instructions) {
    return new _InterpretedArm7TdmiProgram(
      cpu,
      _decoder,
      instructions.toList(),
    );
  }
}

/// An abstraction for a loaded ARM7/TDMI application that can be executed.
abstract class Arm7TdmiProgram {
  /// Runs the next instruction.
  void step();
}

class _InterpretedArm7TdmiProgram implements Arm7TdmiProgram {
  final Arm7Tdmi _cpu;
  final Arm7TdmiDecoder _decoder;
  final List<int> _instructions;

  const _InterpretedArm7TdmiProgram(
    this._cpu,
    this._decoder,
    this._instructions,
  );

  @override
  void step() {
    final instruction = _instructions[_cpu.gprs.pc];
    final decoded = _decoder.decodeArm(instruction);
    decoded.interpret(_cpu, instruction);
  }
}
