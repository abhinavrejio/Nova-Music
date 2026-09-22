import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player/providers/playback/sleep_timer_provider.dart';

void main() {
  test('Sleep timer can be set and cancelled', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(sleepTimerProvider.notifier);
    notifier.setTimer(const Duration(minutes: 30));
    expect(container.read(sleepTimerProvider), const Duration(minutes: 30));

    notifier.setTimer(null);
    expect(container.read(sleepTimerProvider), isNull);
  });
}