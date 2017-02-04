A GameBody Advanced Emulator for Dart.

[![Build Status](https://travis-ci.org/matanlurey/gba.dart.svg?branch=master)](https://travis-ci.org/matanlurey/gba.dart)

[gba]: https://github.com/matanlurey/gba.dart/blob/master/gba/README.md

## [gba][]

Defines the public interface for using the emulator, or for embedding it on
different platforms. This package is *platform agnostic*, and does not contain
any code that loads, displays, or otherwise actually runs a ROM.

### Planned packages

* `gba_browser`: Embeds the emulator to run in the browser using Canvas/WebGL
* `gba_flutter`: Embeds the emulator to run on mobile devices using [Flutter][]
* `gba_server`: Embeds the emulator tu run on the server and streams back

[Flutter]: https://flutter.io
