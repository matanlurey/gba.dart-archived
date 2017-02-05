import 'package:test/test.dart';

/*
  mov r0, #3
  mov r1, #1

  push {r0}
  mov r0, r1
  pop {r1} ; not a typo

  This code swaps the values of r0 and r1 simply by putting the value of r0 on
  the stack, then copying r1 onto r0. It then removes the value that was on r0
  but places it on r1 instead. This might be thoroughly confusing, so here is
  another, step by step explanation.
*/

main() {
  test(
    'should swap the values of r0 and r1',
    () {},
    skip: 'Needs implementation',
  );
}
