part of arm7_tdmi.src.operation;

class Logical {
  const Logical._();

  final test = const Operation._(
    'Test',
  );

  final testEquivalence = const Operation._(
    'Test equivalence',
  );

  final and = const Operation._(
    'AND',
  );

  final eor = const Operation._(
    'EOR',
  );

  final orr = const Operation._(
    'ORR',
  );

  final bitClear = const Operation._(
    'Bit clear',
  );
}
