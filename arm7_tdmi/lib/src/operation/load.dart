part of arm7_tdmi.src.operation;

class Load {
  const Load._();

  final word = const Operation._(
    'Word',
  );

  final wordWithUserModePrivilege = const Operation._(
    'Word with user-mode privilege',
  );

  final byte = const Operation._(
    'Byte',
  );

  final byteWithUserModePrivilege = const Operation._(
    'Byte with user-mode privilege',
  );

  final byteSigned = const Operation._(
    'Byte signed',
  );

  final halfWord = const Operation._(
    'Halfword',
  );

  final halfWordSigned = const Operation._(
    'Halfword signed',
  );

  final incrementBefore = const Operation._(
    'Increment before',
  );

  final incrementAfter = const Operation._(
    'Increment after',
  );

  final decrementBefore = const Operation._(
    'Decrement before',
  );

  final decrementAfter = const Operation._(
    'Decrement after',
  );

  final stackOperation = const Operation._(
    'Stack operation',
  );

  final stackOperationAndRestoreCpsr = const Operation._(
    'Stack operation and restore CPSR',
  );

  final stackOperationWithUserRegisters = const Operation._(
    'Stack operation with user registers',
  );
}
