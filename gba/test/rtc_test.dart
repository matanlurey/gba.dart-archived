import 'package:gba/gba.dart';
import 'package:quiver/time.dart';
import 'package:test/test.dart';

void main() {
  group('$RealTimeClock', () {
    RealTimeClock rtc;

    test('#update', () {
      rtc = new RealTimeClock(
        clock: new Clock.fixed(
          // 1/1/17 @ 3PM.
          new DateTime(
            2017,
            1,
            1,
            15,
          ),
        ),
      );

      rtc.update();
      expect(rtc.time, [23, 1, 1, 6, 21, 0, 0]);
    });
  });
}
