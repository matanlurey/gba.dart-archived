import 'package:binary/binary.dart';
import 'package:gba/src/video/control_register.dart';
import 'package:test/test.dart';

void main() {
  group('$DisplayControlRegister', () {
    DisplayControlRegister register;
    int registerValue = 0;

    void commonSetUp(int newRegisterValue) {
      registerValue = newRegisterValue;
      register = new DisplayControlRegister(
          read: () => registerValue,
          write: (int newValue) {
            registerValue = newValue;
          });
    }

    tearDown(() {
      // Ensure we never forget to call commonSetUp.
      register = null;
      registerValue = 0;
    });

    test('isGameBoyColor should return true iff bit 3 is set', () {
      commonSetUp(7);
      expect(register.isGameBoyColor, isFalse);
      commonSetUp(8);
      expect(register.isGameBoyColor, isTrue);
    });

    test('page should return bit 4', () {
      commonSetUp(15);
      expect(register.page, 0);
      commonSetUp(16);
      expect(register.page, 1);
    });

    test('forceBlank should set bit 7', () {
      commonSetUp(0);
      expect(getBit(registerValue, 7), 0);

      register.forceBlank();
      expect(getBit(registerValue, 7), 1);
    });

    test('enableBackground0 should set bit 8', () {
      commonSetUp(0);
      expect(getBit(registerValue, 8), 0);

      register.enableBackground0();
      expect(getBit(registerValue, 8), 1);
    });

    test('enableBackground1 should set bit 9', () {
      commonSetUp(0);
      expect(getBit(registerValue, 9), 0);

      register.enableBackground1();
      expect(getBit(registerValue, 9), 1);
    });

    test('enableBackground2 should set bit 10', () {
      commonSetUp(0);
      expect(getBit(registerValue, 10), 0);

      register.enableBackground2();
      expect(getBit(registerValue, 10), 1);
    });

    test('enableObject should set bit 12', () {
      commonSetUp(0);
      expect(getBit(registerValue, 12), 0);

      register.enableObject();
      expect(getBit(registerValue, 12), 1);
    });

    test('enableWindow0 should set bit 13', () {
      commonSetUp(0);
      expect(getBit(registerValue, 13), 0);

      register.enableWindow0();
      expect(getBit(registerValue, 13), 1);
    });

    test('enableWindow1 should set bit 14', () {
      commonSetUp(0);
      expect(getBit(registerValue, 14), 0);

      register.enableWindow1();
      expect(getBit(registerValue, 14), 1);
    });

    test('enableObjectWindow should set bit 15', () {
      commonSetUp(0);
      expect(getBit(registerValue, 15), 0);

      register.enableObjectWindow();
      expect(getBit(registerValue, 15), 1);
    });
  });
}
