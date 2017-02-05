part of arm7_tdmi.src.operation;

class Arithmetic {
  const Arithmetic._();

  final add = const Operation._(
    'ADD',
    'Add',
  );

  final addWithCarry = const Operation._(
    'ADC',
    'Add with Carry',
  );

  final subtract = const Operation._(
    'SUB',
    'Subtract',
  );

  final subtractWithCarry = const Operation._(
    'SBC',
    'Subtract with Carry',
  );

  final subtractReverseSubtract = const Operation._(
    'RSB',
    'Subtract reverse subtract',
  );

  final subtractReverseSubtractWithCarry = const Operation._(
    'RSC',
    'Subtract reverse subtract with Carry',
  );

  final multiply = const Operation._(
    'MUL',
    'Multiply',
  );

  final multiplyAccumulate = const Operation._(
    'MLA',
    'Multiply accumulate',
  );

  final multiplyUnsignedLong = const Operation._(
    'UMULL',
    'Multiply unsigned long',
  );

  final multiplyUnsignedAccumulateLong = const Operation._(
    'UMLAL',
    'Multiply unsigned accumulate long',
  );

  final multiplySignedLong = const Operation._(
    'SMULL',
    'Multiply signed long',
  );

  final multiplySignedAccumulateLong = const Operation._(
    'SMLAL',
    'Multiply signed accumulate long',
  );

  final compare = const Operation._(
    'CMP',
    'Compare',
  );

  final compareNegative = const Operation._(
    'CMN',
    'Compare negative',
  );
}
