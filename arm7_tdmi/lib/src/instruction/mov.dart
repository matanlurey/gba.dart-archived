part of arm7_tdmi.src.instruction;

class MOV$ extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const MOV$._()
      : super._(
          format: const DataProcessingOrPsrTransfer(),
          opcode: 13,
          suffix: 'MOV',
        );

  @override
  void execute({
    @required Arm7TdmiRegisters gprs,
    @required int rd,
    @required int shifterOperand,
  }) {
    gprs.set(rd, shifterOperand);
  }

  @override
  bool interpret(
    Arm7Tdmi cpu,
    int instruction,
  ) {
    if (!passes(cpu, instruction)) {
      return false;
    }
    execute(
      gprs: cpu.gprs,
      rd: format.rd(instruction),
      shifterOperand: format.operand(instruction),
    );
    return true;
  }
}
