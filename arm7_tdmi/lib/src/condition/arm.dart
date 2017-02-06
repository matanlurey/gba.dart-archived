import 'package:arm7_tdmi/src/cpu/psr.dart';
import 'package:meta/meta.dart';

/// An ARM7/TDMI bit-string for determining whether an ARM instruction executes.
///
/// Derived from bits `31-28` of an `ARM` instruction.
abstract class Arm7TdmiCondition {
  static const EQ = const _Equal();
  static const NE = const _NotEqual();
  static const CS = const _CarrySet();
  static const CC = const _CarryCleared();
  static const MI = const _Negative();
  static const PL = const _PositiveOrZero();
  static const VS = const _Overflow();
  static const VC = const _NoOverflow();
  static const HI = const _UnsignedHigher();
  static const LS = const _UnsignedLowerOrSame();
  static const GE = const _GreaterOrEqual();
  static const LT = const _LessThan();
  static const GT = const _GreaterThan();
  static const LE = const _LessOrEqual();
  static const AL = const _Always();
  static const NV = const _Never();

  static final _byCode = new Map.fromIterable(values, key: (v) => v.code);
  static const values = const [
    EQ,
    NE,
    CS,
    CC,
    MI,
    PL,
    VS,
    VC,
    HI,
    LS,
    GE,
    LT,
    GT,
    LE,
    AL,
    NV,
  ];

  /// Bit code value.
  final int code;

  /// Suffix mnemonic.
  final String suffix;

  /// Meaning.
  final String description;

  /// Returns a condition by decoding [value].
  factory Arm7TdmiCondition.decode(int value) => _byCode[value];

  const Arm7TdmiCondition._({
    @required
    this.code,
    @required
    this.suffix,
    @required
    this.description,
  });

  /// Whether the condition should pass given the [cpsr].
  bool passes(Arm7TdmiPsr cpsr);

  @override
  String toString() => '$suffix';
}

class _Equal extends Arm7TdmiCondition {
  const _Equal() : super._(
    code: 0x0,
    suffix: 'EQ',
    description: 'equal (zero) (same)',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => cpsr.z;
}

class _NotEqual extends Arm7TdmiCondition {
  const _NotEqual() : super._(
    code: 0x1,
    suffix: 'NE',
    description: 'not equal (nonzero) (not same)'
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => !cpsr.z;
}

class _CarrySet extends Arm7TdmiCondition {
  const _CarrySet() : super._(
    code: 0x2,
    suffix: 'CS',
    description: 'unsigned higher or same (carry set)',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => cpsr.c;
}

class _CarryCleared extends Arm7TdmiCondition {
  const _CarryCleared() : super._(
      code: 0x3,
      suffix: 'CC',
      description: 'unsigned lower (carry cleared)',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => !cpsr.c;
}

class _Negative extends Arm7TdmiCondition {
  const _Negative() : super._(
      code: 0x4,
      suffix: 'MI',
      description: 'negative (minus)',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => cpsr.n;
}

class _PositiveOrZero extends Arm7TdmiCondition {
  const _PositiveOrZero() : super._(
      code: 0x5,
      suffix: 'PL',
      description: 'positive or zero (plus)',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => !cpsr.n;
}

class _Overflow extends Arm7TdmiCondition {
  const _Overflow() : super._(
      code: 0x6,
      suffix: 'VS',
      description: 'overflow (V set)',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => cpsr.v;
}

class _NoOverflow extends Arm7TdmiCondition {
  const _NoOverflow() : super._(
      code: 0x7,
      suffix: 'VC',
      description: 'no overflow (V cleared)',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => !cpsr.v;
}

class _UnsignedHigher extends Arm7TdmiCondition {
  const _UnsignedHigher() : super._(
      code: 0x8,
      suffix: 'HI',
      description: 'unsigned higher',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => cpsr.c && !cpsr.n;
}

class _UnsignedLowerOrSame extends Arm7TdmiCondition {
  const _UnsignedLowerOrSame() : super._(
      code: 0x9,
      suffix: 'LS',
      description: 'unsigned lower or same',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => !cpsr.c || cpsr.n;
}

class _GreaterOrEqual extends Arm7TdmiCondition {
  const _GreaterOrEqual() : super._(
      code: 0xA,
      suffix: 'GE',
      description: 'greater or equal',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => cpsr.n == cpsr.v;
}

class _LessThan extends Arm7TdmiCondition {
  const _LessThan() : super._(
      code: 0xB,
      suffix: 'LT',
      description: 'less than',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => cpsr.n != cpsr.v;
}

class _GreaterThan extends Arm7TdmiCondition {
  const _GreaterThan() : super._(
      code: 0xC,
      suffix: 'GT',
      description: 'greater than',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => !cpsr.z && cpsr.n == cpsr.v;
}

class _LessOrEqual extends Arm7TdmiCondition {
  const _LessOrEqual() : super._(
      code: 0xD,
      suffix: 'LE',
      description: 'less or equal',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => cpsr.z || cpsr.n != cpsr.v;
}

class _Always extends Arm7TdmiCondition {
  const _Always() : super._(
      code: 0xE,
      suffix: 'AL',
      description: 'always',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => true;
}

class _Never extends Arm7TdmiCondition {
  const _Never() : super._(
      code: 0xF,
      suffix: 'NV',
      description: 'never',
  );

  @override
  bool passes(Arm7TdmiPsr cpsr) => false;
}
