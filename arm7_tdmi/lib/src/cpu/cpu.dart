/// A 32-bit `RISC` (Reduced Instruction Set Computer) CPU emulator.
///
/// ## Fast execution
///
/// Depending on the CPU state, all opcodes are sized 32bit of 16bit (that's
/// counting both the opcode bits and its parameter bits) providing fast
/// decoding and execution. Additionally, pipe-lining allows - (a) one
/// instruction to be executed while (b) the next instruction is decoded and (c)
/// the next instruction is fetched from memory - all at the same time.
///
/// ## Data formats
///
/// The CPU manages to deal with 8bit, 16bit, and 32bit data that are called:
///
/// * 8bit - `Byte`
/// * 16bit - `Half-word`
/// * 32bit - `Word`
///
/// ## Two CPU states
///
/// As mentioned above, two CPU states exist:
///
/// * `ARM` state: Uses the full 32bit instruction set (32bit opcodes)
/// * `THUMB` state: Uses a cut-down 16bit instruction set (16bit opcodes)
///
/// Regardless of opcode-width, both states use 32bit registers, allowing 32bit
/// memory addressing as well as 32bit arithmetic/logical operations.
///
/// ### When to use `ARM` state
///
/// Two advantages to using `ARM`:
///
/// * Each single opcode provides more functionality, resulting in faster
///   execution when using a 32bit bus memory system (such as opcodes stored in
///   GBA work RAM).
/// * All registers `R0-R15` can be accessed directly.
///
/// The downsides are:
///
/// * Not as fast when using 16bit memory system (but it still works though)
/// * Program code occupies more memory space
///
/// ### When to use `THUMB` state
///
/// Two advantages to using `THUMB`:
///
/// * Faster execution up to approximately 160% when using a 16bit bus memory
///   system (such as opcodes stored in GBA GamePak ROM).
/// * Reduces code size, decreases memory overload down to approximately 65%.
///
/// The downsides are:
///
/// * Not as multi-functional opcodes as in `ARM` state, so it will be sometimes
///   required to use more than one opcode to gain a similar result for a single
///   opcode in the `ARM` state.
/// * Most opcodes allow only registers `R0-R7` to be used directly.
///
/// ## Combining `ARM` and `THUMB` state
///
/// Switching between `ARM` and `THUMB` is done by a normal branch (`BX`)
/// instruction which takes only a handful of cycles to execute (allowing for
/// state changes as often as desired - with almost no overload).
///
/// Also as both `ARM` and `THUMB` use the same register set, it is possible to
/// pass data between `ARM` and `THUMB` mode very easily.
///
/// The best memory and execution performance can be gained by combining both
/// states: `THUMB` for normal program code, and `ARM` code for timing critical
/// subroutines (such like interrupt handlers, or complicated algorithms).
///
/// **Note**: `ARM` and `THUMB` code cannot be executed simultaneously.
///
/// ## Automatic state changes
///
/// Beside for the above manual state switching by using `BX` instructions, th
/// following situations involve automatic state changes:
///
/// * CPU switches to ARM state when executing an exception
/// * User switches back to old state when leaving an exception
abstract class Arm7Tdmi {
  // TODO: Implement.
}
