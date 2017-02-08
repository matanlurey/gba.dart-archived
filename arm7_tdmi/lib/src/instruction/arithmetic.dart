import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:binary/binary.dart';

void adc(
    {Arm7TdmiOperatingMode mode,
    Arm7TdmiRegisters gprs,
    Arm7TdmiCondition condition,
    int rd,
    int rn,
    int shifterOperand,
    bool updatesSpsr}) {
  final op1 = int32.mask(gprs.get(rn));
  final op2 = int32.mask(shifterOperand + (gprs.cpsr.c ? 1 : 0));
  final trueResult = op1 + op2;

  if (!condition.passes(gprs.cpsr)) {
    return;
  }

  if (updatesSpsr && rd == 15) {
    if (mode.canAccessSpsr) {
      // set cpsr to spsr.
      throw new UnimplementedError();
    } else {
      // unpredictable
      throw new UnimplementedError();
    }
  } else {
    gprs.cpsr.n = int32.sign(trueResult) == 1;
    gprs.cpsr.z = gprs.get(rd) == 0;
    gprs.cpsr.c = int32.hasCarryBit(trueResult);
    gprs.cpsr.v = int32.isAddOverflow(op1, op2, trueResult);
  }
}

void add(
    {Arm7TdmiOperatingMode mode,
    Arm7TdmiRegisters gprs,
    Arm7TdmiCondition condition,
    int rd,
    int rn,
    int shifterOperand,
    bool updatesSpsr}) {
  if (!condition.passes(gprs.cpsr)) {
    return;
  }
  final op1 = int32.mask(gprs.get(rn));
  final trueResult = op1 + int32.mask(shifterOperand);

  gprs.set(rd, trueResult);
  if (updatesSpsr && rd == 15) {
    if (mode.canAccessSpsr) {
      // set cpsr to spsr.
      throw new UnimplementedError();
    } else {
      // unpredictable
      throw new UnimplementedError();
    }
  } else {
    gprs.cpsr.n = int32.sign(trueResult) == 1;
    gprs.cpsr.z = gprs.get(rd) == 0;
    gprs.cpsr.c = int32.hasCarryBit(trueResult);
    gprs.cpsr.v = int32.isAddOverflow(op1, shifterOperand, trueResult);
  }
}
