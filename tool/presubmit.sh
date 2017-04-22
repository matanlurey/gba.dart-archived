#!/bin/bash
# Runs all of the presubmit checks on every pub package in this repository.
#
# For a faster dev-cycle, use `pub global run presubmit` yourself in a package.

function run_coveralls {
  if [ "$COVERALLS_TOKEN" ] && [ "$TRAVIS_DART_VERSION" = "stable" ]; then
    dart tool/create_test_all.dart
    # Unfortunately, dart_coveralls only supports this older format.
    pub get --no-packages-dir
    pub global activate dart_coveralls
    pub global run dart_coveralls report \
      --retry 2 \
      --exclude-test-files \
      tool/test_all.dart
    rm tool/test_all.dart
  fi
}

# Fast fail the script on failures.
set -e

# Download the presubmit runner.
pub global activate presubmit

pushd binary
pub upgrade
pub global run presubmit
run_coveralls
popd

pushd arm7_tdmi
pub upgrade
pub global run presubmit
run_coveralls
popd

pushd gba
pub upgrade
pub global run presubmit
run_coveralls
popd
