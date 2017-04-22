part of arm7_tdmi.src.instruction;

class ADC$ extends Arm7TdmiInstruction<DataProcessingOrPsrTransfer> {
  const ADC$._()
      : super._(
          format: const DataProcessingOrPsrTransfer(),
          opcode: 5,
          suffix: 'ADC',
        );

  @override
  String disassemble(int instruction) {
    final cond = new Arm7TdmiCondition.decode(instruction);
    final rd = format.rd(instruction);
    final rn = format.rn(instruction);
    final op2 = format.operand(instruction);
    return 'ADC{$cond} Rd=$rd,Rn=$rn,Op2=$op2';
  }

  @override
  void execute({
    @required Arm7TdmiRegisters gprs,
    @required int rd,
    @required int rn,
    @required int op2,
  }) {
    if (gprs.cpsr.c) {
      op2++;
    }
    final op1 = uint32.mask(gprs.get(rn));
    final result = op1 + op2;
    gprs.set(rd, result);
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
