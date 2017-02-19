part of arm7_tdmi.src.instruction;

class ADDS$ extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const ADDS$._()
      : super._(
          format: const DataProcessingOrPsrTransfer(),
          opcode: 0,
          suffix: 'ADDS',
        );

  @override
  void execute({
    @required Arm7TdmiRegisters gprs,
    @required int rd,
    @required int rn,
    @required int op2,
  }) {
    final op1 = uint32.mask(gprs.get(rn));
    final result = op1 + op2;
    gprs.set(rd, result);
    // TODO: If rd == program counter.
    gprs.cpsr
      ..n = uint32.isNegative(result)
      ..z = isZero(rd)
      ..c = uint32.hasCarryBit(result)
      ..v = uint32.doesAddOverflow(op1, op2, result);
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
      op2: format.operand(instruction),
    );
    return true;
  }
}
