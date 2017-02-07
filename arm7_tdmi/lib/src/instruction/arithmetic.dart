import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:arm7_tdmi/src/utils/bits.dart';
import 'package:binary/binary.dart';

void add(
    {Arm7TdmiOperatingMode mode,
    Arm7TdmiRegisters gprs,
    Arm7TdmiCondition condition,
    int rd,
    int rn,
    int shifterOperand,
    bool updatesSpsr}) {
  if (condition.passes(gprs.cpsr)) {
    final op1 = gprs.get(rn);
    final trueResult = uint32.add(op1, shifterOperand);
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
      gprs.cpsr.n = sign(trueResult) == 1;
      gprs.cpsr.z = rd == 0;
      gprs.cpsr.c = carryFrom(trueResult) == 1;
      gprs.cpsr.v = overflowFromAdd(op1, shifterOperand, trueResult) == 1;
    }
  }
}
