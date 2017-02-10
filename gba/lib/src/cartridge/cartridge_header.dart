/// A GameBoy Advance Cartridge Header
///
/// Technical information can be found at http://problemkaputt.de/gbatek.htm
abstract class GameCatridgeHeader {
  /// A 32-bit ARM Branch opcode, eg. "B rom_start".
  ///
  /// This opcode redirects to the actual start address of the cartridge.
  ///
  /// Size: 4bytes
  int get entryPoint;

  /// Contains the nintendo logo which is displayed during the boot procedure.
  ///
  /// The cartridge won't work if this data is missing or modified.
  ///
  /// Size: 156bytes
  List<int> get nintendoLogo;

  /// Part of the [nintendoLogo] area which must commonly be set to 0x21.
  ///
  /// Bits 2 and 7 may be set to other values.  When both bits are set (e.g.
  /// [debuggingEnable] == 0xA5), the FIQ/Undefined instruction handler in the
  /// BIOS becomes unlocked.  The handler then forwards these exceptions to the
  /// user handler in cartridge ROM (where the entry point is defined by
  /// [entryPoint].
  ///
  /// Size: 1byte
  int get debuggingEnable;

  /// Part of the [nintendoLogo] area which must commonly be set to 0xF8.
  ///
  /// Bits 0 and 1 may be set to other values.  During startup, the BIOS
  /// performs some dummy-reads from a stream of pre-defined addresses, even
  /// though these reads seem to be meaningless, they might be intended to
  /// unlock a read-protection inside of commercial cartridges.
  ///
  /// Size: 1byte
  int get cartridgeKeyNumberMSBs;

  /// The ascii game title.
  ///
  /// This has a maximum length of 12 characters.  A title with fewer than 12
  /// characters is padded with zeroes.
  ///
  /// Size: 12bytes
  List<int> get gameTitle;

  /// The code printed on a commercial cartridges package and sticker.
  ///
  /// The code is 4 digits and follows the format UTTD where:
  /// - U is a *unique* code. for example:
  ///   - A  Normal game; Older titles (mainly 2001..2003)
  ///   - B  Normal game; Newer titles (2003..)
  ///   - C  Normal game; Not used yet, but might be used for even newer titles
  ///   - F  Famicom/Classic NES Series (software emulated NES games)
  ///   - K  Yoshi and Koro Koro Puzzle (acceleration sensor)
  ///   - P  e-Reader (dot-code scanner)
  ///   - R  Warioware Twisted (cartridge with rumble and z-axis gyro sensor)
  ///   - U  Boktai 1 and 2 (cartridge with RTC and solar sensor)
  ///   - V  Drill Dozer (cartridge with rumble)
  ///
  /// - TT is the short title of the game (e.g. "PM" for Pac Man) unless that
  ///   game code was already used for another game. Then TT is random.
  ///
  /// - D indicates the destination/language and is one of the following:
  ///   - J  Japan
  ///   - P  Europe/Elsewhere
  ///   - F  French
  ///   - S  Spanish
  ///   - E  USA/English
  ///   - D  German
  ///   - I  Italian
  ///
  /// Size: 4bytes
  int get gameCode;

  /// A code identifying the commercial developer (e.g. "01"=Nintendo)
  ///
  /// Size: 2bytes
  List<int> get makerCode;

  /// A fixed value that must always be 0x96
  ///
  /// Size: 1byte
  int get fixedValue;

  /// Identifies the required hardware.
  ///
  /// Should be 00h for current GBA models.
  ///
  /// Size: 1byte
  int get mainUnitCode;

  /// Used to identify the debugging handler's entry point and DACS memory size.
  ///
  /// DACS stands for "Debugging and Communication System".  Normally this entry
  /// should be 0.
  ///
  /// Size: 1byte
  // TODO(kjharland): Add docs for what it means when this isn't 0.
  int get deviceType;

  /// The version number of the game, usually zero.
  ///
  /// Size: 1byte
  int get softwareVersionNumber;

  /// The header checksum.
  ///
  /// The cartridge will not work if this is incorrect.
  ///
  /// Size: 1byte
  int get complementCheck;

  /* Multiboot/Slave data omitted */
}
