# arm7_tdmi

An emulator for the ARM7/TDMI processor.

[![Pub](https://img.shields.io/pub/v/arm7_tdmi.svg)](https://pub.dartlang.org/packages/arm7_tdmi)
[![Build Status](https://travis-ci.org/matanlurey/gba.dart.svg?branch=master)](https://travis-ci.org/matanlurey/gba.dart)
[![Coverage Status](https://coveralls.io/repos/github/matanlurey/gba.dart/badge.svg?branch=master)](https://coveralls.io/github/matanlurey/gba.dart?branch=master)
[![documentation](https://img.shields.io/badge/Documentation-arm7_tdmi-blue.svg)](https://www.dartdocs.org/documentation/arm7_tdmi/latest)

This project is primarily academic/educational, and prefers idiomatic Dart and
readability over performance. After completion it should be executable on any
major platform, including the web, standalone VM, and Flutter.

## Progress

**WARNING**: Largely incomplete and not ready for use.

Goals (*subject to change*):

- [ ] Be able to run (emulated) programs compiled for the ARM7/TDMI
- [ ] A web and command-line interface for testing/debugging compiled programs
- [ ] Use in other emulator projects (educational only)
- [ ] An end-to-end example of a large/complex cross-platform library for Dart
- [ ] A test suite for others to write their own processor implementations

## Learning more about the ARM7/TDMI

Notable uses of this processor include:

* Microsoft Zune HD
* Nintendo DS
* Nintendo GameBoy Advance
* Nokia 6110
* Sega Dreamcast

If you're interested in learning more about this processor read the dartdocs
in this package or you can view various collected PDFS and documents on the
topic in the main repository - [github.com/matanlurey/gba.dart][gba.dart].

[gba.dart]: https://github.com/matanlurey/gba.dart

* [Wikipedia for ARM7/TDMI][wiki]
* [ARM7/TDMI CPU Overview][overview]
* [ARM7/TDMI Manual][manual]
* [Official ARM7/TDMI Documentation][docs]

[wiki]: https://en.wikipedia.org/wiki/ARM7#ARM7TDMI
[overview]: https://github.com/matanlurey/gba.dart/blob/master/doc/ARM_CPU_OVERVIEW.pdf
[manual]: http://www.atmel.com/images/ddi0029g_7tdmi_r3_trm.pdf
[docs]: https://www.scss.tcd.ie/~waldroj/3d1/arm_arm.pdf
