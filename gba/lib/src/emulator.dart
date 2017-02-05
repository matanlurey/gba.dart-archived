/// GameBoy Advanced Emulator entrypoint - use to implement a frontend.
abstract class Emulator {
  factory Emulator() = _DefaultEmulator;

  /// Whether the emulator is executing.
  bool get isRunning;

  /// Stops execution of the emulator, clearing any state.
  void stop();

  /// Starts execution of the emulator.
  void run();
}

class _DefaultEmulator implements Emulator {
  @override
  var isRunning = false;

  @override
  void stop() {
    assert(() {
      if (!isRunning) {
        throw new AssertionError('Not running');
      }
      return true;
    });
    isRunning = false;
  }

  @override
  void run() {
    assert(() {
      if (isRunning) {
        throw new AssertionError('Already running');
      }
      return true;
    });
    isRunning = true;
  }
}
