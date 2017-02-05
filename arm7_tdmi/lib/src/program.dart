import 'dart:async';

/// Compiles an ARM7-TDMI instruction set into an executable [Program].
abstract class Compiler {
  /// Creates a new program by compiling [instructions].
  Future<Program> compile(instructions);
}

/// Creates an executable program that interprets a program incrementally,
class Interpreter implements Compiler {
  const Interpreter();

  @override
  Future<Program> compile(instructions) {
    throw new UnimplementedError();
  }
}

/// An encapsulated ARM7-TDMI program/instructions that can be executed.
abstract class Program {
  /// Executes the program in the context of the given [cpu] and [memory].
  void execute(cpu, memory);
}
