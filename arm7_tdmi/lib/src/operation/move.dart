part of arm7_tdmi.src.operation;

class Move {
  const Move._();

  final move = const Operation._(
    'MOV',
    'Move',
  );

  final moveNot = const Operation._(
    'MVN',
    'Move NOT',
  );

  final moveSpsrToRegister = const Operation._(
    'MRS',
    'Move SPRS to register',
  );

  final movwCpsrToRegister = const Operation._(
    'MRS',
    'Move CPSR to register',
  );

  final moveRegisterToSpsr = const Operation._(
    'MSR',
    'Move register to SPSR',
  );

  final moveRegisterToCpsr = const Operation._(
    'MSR',
    'Move register to CPSR',
  );

  final moveImmediateToSpsrFlags = const Operation._(
    'MSR',
    'Move immediate to SPSR flags',
  );

  final moveImmediateToCpsrFlags = const Operation._(
    'MSR',
    'Move immediate to CPSR flags',
  );
}
