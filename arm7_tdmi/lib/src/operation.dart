library arm7_tdmi.src.operation;

part 'operation/arithmetic.dart';
part 'operation/branch.dart';
part 'operation/coprocessors.dart';
part 'operation/interrupt.dart';
part 'operation/load.dart';
part 'operation/logical.dart';
part 'operation/move.dart';
part 'operation/store.dart';

class Operation {
  final String name;
  final String description;

  const Operation._(this.name, this.description);
}

/// Operations related to arithmetic.
const arithmetic = const Arithmetic._();

/// Operations related to branching.
const branch = const Branch._();

/// Operations related to coprocessors.
const coprocessors = const Coprocessors._();

/// Operations related to interrupting.
const interrupt = const Interrupt._();

/// Operations related to loading.
const load = const Load._();

/// Operations related to logical.
const logical = const Logical._();

/// Operations related to moving.
const move = const Move._();

/// Operations related to storing.
const store = const Store._();
