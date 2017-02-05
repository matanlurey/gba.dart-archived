part of arm7_tdmi.src.operation;

class Arithmetic {
  const Arithmetic._();

  final add = const Operation._(
    'Add',
  );
  final addWithCarry = const Operation._(
    'Add with Carry',
  );
  final subtract = const Operation._(
    'Subtract',
  );
  final subtractWithCarry = const Operation._(
    'Subtract with Carry',
  );
  final subtractReverseSubtract = const Operation._(
    'Subtract reverse subtract',
  );
  final subtractReverseSubtractWithCarry = const Operation._(
    'Subtract reverse subtract with Carry',
  );
  final multiply = const Operation._(
    'Multiply',
  );
  final multiplyAccumulate = const Operation._(
    'Multiply accumulate',
  );
  final multiplyUnsignedLong = const Operation._(
    'Multiply unsigned accumulate long',
  );
  final multiplySignedLong = const Operation._(
    'Multiply signed long',
  );
  final compare = const Operation._(
    'Compare',
  );
  final compareNegative = const Operation._(
    'Compare negative',
  );
}
