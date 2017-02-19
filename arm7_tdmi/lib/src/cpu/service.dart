import 'package:arm7_tdmi/arm7_tdmi.dart';

/// A device service that allows ARM to call system-level services.
///
/// The default implementation does nothing.
class Arm7TdmiService {
  const Arm7TdmiService();

  /// Invoked when a system-level service call is attempted by [cpu].
  void call(Arm7Tdmi cpu) {}
}
