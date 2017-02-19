import 'package:arm7_tdmi/arm7_tdmi.dart';

/// A generic pin on an integrated circuit or computer board.
class GeneralPurposeIO {
  final MemoryAccess _memory;

  int _direction = 0;
  int _readWrite = 0;

  GeneralPurposeIO(this._memory);
}
