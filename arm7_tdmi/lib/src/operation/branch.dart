part of arm7_tdmi.src.operation;

class Branch {
  const Branch._();

  final branch = const Operation._(
    'Branch',
  );

  final branchWithLink = const Operation._(
    'Branch with link',
  );

  final branchAndExchangeInstructionSet = const Operation._(
    'Branch and exchange instruction set',
  );
}
