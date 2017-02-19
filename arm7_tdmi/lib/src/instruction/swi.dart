part of arm7_tdmi.src.instruction;

class SWI$ extends Arm7TdmiInstruction<SoftwareInterrupt> {
  const SWI$._()
      : super._(
          format: const SoftwareInterrupt(),
          opcode: null,
          suffix: 'SWI',
        );

  @override
  void execute({@required Arm7Tdmi cpu}) {
    cpu.service.call(cpu);
  }

  @override
  bool interpret(
    Arm7Tdmi cpu,
    int instruction,
  ) {
    if (!passes(cpu, instruction)) {
      return false;
    }
    // TODO: Implement.
    execute(cpu: cpu);
    return true;
  }
}
