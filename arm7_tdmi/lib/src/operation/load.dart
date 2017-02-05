part of arm7_tdmi.src.operation;

class Load {
  const Load._();

  final word = const Operation._(
    'LDR',
    'Word',
  );

  final wordWithUserModePrivilege = const Operation._(
    'LDR',
    'Word with user-mode privilege',
  );

  final byte = const Operation._(
    'LDR',
    'Byte',
  );

  final byteWithUserModePrivilege = const Operation._(
    'LDR',
    'Byte with user-mode privilege',
  );

  final byteSigned = const Operation._(
    'LDR',
    'Byte signed',
  );

  final halfWord = const Operation._(
    'LDR',
    'Halfword',
  );

  final halfWordSigned = const Operation._(
    'LDR',
    'Halfword signed',
  );

  final incrementBefore = const Operation._(
    'LDM',
    'Increment before',
  );

  final incrementAfter = const Operation._(
    'LDM',
    'Increment after',
  );

  final decrementBefore = const Operation._(
    'LDM',
    'Decrement before',
  );

  final decrementAfter = const Operation._(
    'LDM',
    'Decrement after',
  );

  final stackOperation = const Operation._(
    'LDM',
    'Stack operation',
  );

  final stackOperationAndRestoreCpsr = const Operation._(
    'LDM',
    'Stack operation and restore CPSR',
  );

  final stackOperationWithUserRegisters = const Operation._(
    'LDM',
    'Stack operation with user registers',
  );
}
