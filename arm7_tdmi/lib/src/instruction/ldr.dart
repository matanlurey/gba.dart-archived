part of arm7_tdmi.src.instruction;

class LDR$ extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const LDR$._()
      : super._(
          format: const DataProcessingOrPsrTransfer(),
          opcode: null,
          suffix: 'LDR',
        );

  @override
  String disassemble(int instruction) {
    final cond = new Arm7TdmiCondition.decode(instruction);
    return 'LDR{$cond} ???????????????';
  }

  @override
  void execute() {}

  @override
  bool interpret(
    Arm7Tdmi cpu,
    int instruction,
  ) {
    if (!passes(cpu, instruction)) {
      return false;
    }
    // TODO: Implement.
    execute();
    return true;
  }
}
