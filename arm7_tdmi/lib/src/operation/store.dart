part of arm7_tdmi.src.operation;

class Store {
  const Store._();

  final word = const Operation._(
    'STR',
    'Word',
  );

  final wordWithUserModePrivilege = const Operation._(
    'STR',
    'Word with user-mode privilege',
  );

  final byte = const Operation._(
    'STR',
    'Byte',
  );

  final byteWithUserModePrivilege = const Operation._(
    'STR',
    'Byte with user-mode privilege',
  );

  final byteSigned = const Operation._(
    'STR',
    'Byte signed',
  );

  final halfWord = const Operation._(
    'STR',
    'Halfword',
  );

  final halfWordSigned = const Operation._(
    'STR',
    'Halfword signed',
  );

  final incrementBefore = const Operation._(
    'STM',
    'Increment before',
  );

  final incrementAfter = const Operation._(
    'STM',
    'Increment after',
  );

  final decrementBefore = const Operation._(
    'STM',
    'Decrement before',
  );

  final decrementAfter = const Operation._(
    'STM',
    'Decrement after',
  );

  final stackOperationWithUserRegisters = const Operation._(
    'STM',
    'Stack operations with user registers',
  );
}
