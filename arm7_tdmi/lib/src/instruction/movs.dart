part of arm7_tdmi.src.instruction;

class MOVS$ extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const MOVS$._()
      : super._(
          format: const DataProcessingOrPsrTransfer(),
          opcode: 13,
          suffix: 'MOVS',
        );

  @override
  String disassemble(int instruction) {
    final cond = new Arm7TdmiCondition.decode(instruction);
    final rd = format.rd(instruction);
    final op2 = format.operand(instruction);
    return 'MOV{$cond}{S} Rd=$rd, Op2=$op2';
  }

  @override
  void execute({
    @required Arm7TdmiRegisters gprs,
    @required int rd,
    @required int shifterOperand,
  }) {
    gprs.set(rd, shifterOperand);
    // TODO: If rd == program counter.
    gprs.cpsr
      ..n = uint32.isNegative(gprs.get(rd))
      ..z = isZero(gprs.get(rd))
      // TODO: Update this to shifterCarryOut once implemented.
      ..c = true;
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
