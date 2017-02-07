# binary

Utilities for working with binary data in Dart.

[![Build Status](https://travis-ci.org/matanlurey/gba.dart.svg?branch=master)](https://travis-ci.org/matanlurey/gba.dart)
[![Coverage Status](https://coveralls.io/repos/github/matanlurey/gba.dart/badge.svg?branch=master)](https://coveralls.io/github/matanlurey/gba.dart?branch=master)

## Usage

This library supports an `Integral` data type for fluent bit manipulation:

```dart
print(uint8.toBinaryPadded(196)); // '11000100'
```

Because of Dart's ability to do advanced *inlining* in both the Dart VM and
dart2js, this library should perform well and be extremely easy to use for most
use cases. For example, it's used in an [`arm7_tdmi`][arm7_tdmi] emulator.

[arm7_tdmi]: htps://pub.dartlang.org/packages/arm7_tdmi

See the dartdocs for more about the API.
