import 'dart:io';

import 'package:arm7_tdmi/arm7_tdmi.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  new Directory(p.join('test', 'roms')).listSync().forEach((file) {
    if (file is File) {
      _run(file);
    }
  });
}

void _run(File file) {
  test('should pass ${p.basename(file.path)}', () {
    final cpu = new Arm7Tdmi(gprs: new Arm7TdmiRegisters());
    final instructions = file.readAsBytesSync();
    final program = const Arm7TdmiCompiler().compile(cpu, instructions);
    program.step();
  }, skip: 'Not yet supported');
}
