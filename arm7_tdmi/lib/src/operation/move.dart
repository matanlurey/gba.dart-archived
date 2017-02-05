part of arm7_tdmi.src.operation;

class Move {
  const Move._();

  final move = const Operation._(
    'Move',
  );

  final moveNot = const Operation._(
    'Move NOT',
  );

  final moveSpsrToRegister = const Operation._(
    'Move SPRS to register',
  );

  final movwCpsrToRegister = const Operation._(
    'Move CPSR to register',
  );

  final moveImmediateToSpsrFlags = const Operation._(
    'Move immediate to SPSR flags',
  );

  final moveImmediateToCpsrFlags = const Operation._(
    'Move immediate to CPSR flags',
  );
}
