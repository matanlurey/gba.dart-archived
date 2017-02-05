part of arm7_tdmi.src.operation;

class Logical {
  const Logical._();

  final test = const Operation._(
    'TST',
    'Test',
  );

  final testEquivalence = const Operation._(
    'TEQ',
    'Test equivalence',
  );

  final and = const Operation._(
    'AND',
    'AND',
  );

  final eor = const Operation._(
    'EOR',
    'EOR',
  );

  final orr = const Operation._(
    'ORR',
    'ORR',
  );

  final bitClear = const Operation._(
    'BIC',
    'Bit clear',
  );
}
