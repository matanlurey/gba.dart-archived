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
    assert(isRunning, 'Not running');
    isRunning = false;
  }

  @override
  void run() {
    assert(!isRunning, 'Already running');
    isRunning = true;
  }
}
