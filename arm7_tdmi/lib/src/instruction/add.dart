part of arm7_tdmi.src.instruction;

class ADD$ extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const ADD$._()
      : super._(
          format: const DataProcessingOrPsrTransfer(),
          opcode: 0,
          suffix: 'ADD',
        );

  @override
  int execute({
    @required Arm7TdmiRegisters gprs,
    @required int rd,
    @required int rn,
    @required int op2,
  }) {
    final op1 = uint32.mask(gprs.get(rn));
    final result = op1 + op2;
    gprs.set(rd, result);
    return result;
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
      rn: format.rn(instruction),
      op2: uint32.mask(format.operand(instruction)),
    );
    return true;
  }
}
