part of arm7_tdmi.src.instruction;

// TODO(kharland): Figure out the correct format for this instruction and fix
// hello world test.
class LDR$ extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const LDR$._()
      : super._(
          format: const DataProcessingOrPsrTransfer(),
          opcode: null,
          suffix: 'LDR',
        );

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
