import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';

Future main() async {
  var imports = new StringBuffer();
  var groupCalls = new StringBuffer();
  var i = 0;
  await for (var file in _testGlob.list(followLinks: false)) {
    imports.writeln('import \'../${file.path}\' as i$i;');
    groupCalls.writeln('  group(\'${file.path}\', i$i.main);');
    i++;
  }

  var file = new File('tool/test_all.dart');
  await file.writeAsString('''
$_header
$imports
main() {
$groupCalls
}
  ''');
}

final _testGlob = new Glob('test/**/*_test.dart');

const _header = '''
import 'package:test/test.dart';
''';
