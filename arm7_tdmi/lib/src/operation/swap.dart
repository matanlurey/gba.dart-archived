part of arm7_tdmi.src.operation;

class Swap {
  const Swap._();

  final word = const Operation._(
    'SWP',
    'Word',
  );

  final byte = const Operation._(
    'SWP',
    'Byte',
  );
}
