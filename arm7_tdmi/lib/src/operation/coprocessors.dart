part of arm7_tdmi.src.operation;

class Coprocessors {
  const Coprocessors._();

  final dataOperation = const Operation._(
    'CDP',
    'Data operation',
  );

  final moveToArmRegiserFromCoprocessor = const Operation._(
    'MRC',
    'Move to ARM register from coprocessor',
  );

  final moveToCoprocessorFromArmRegister = const Operation._(
    'MCR',
    'Move to coprocessor from ARM register',
  );

  final load = const Operation._(
    'LDC',
    'Load',
  );

  final store = const Operation._(
    'STC',
    'Store',
  );
}
