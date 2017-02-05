part of arm7_tdmi.src.operation;

class Branch {
  const Branch._();

  final branch = const Operation._(
    'B',
    'Branch',
  );

  final branchWithLink = const Operation._(
    'BL',
    'Branch with link',
  );

  final branchAndExchangeInstructionSet = const Operation._(
    'BX',
    'Branch and exchange instruction set',
  );
}
