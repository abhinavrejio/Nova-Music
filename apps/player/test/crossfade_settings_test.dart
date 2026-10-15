import 'package:flutter_test/flutter_test.dart';
import 'package:player/models/app_settings.dart';

void main() {
  test('crossfade defaults to disabled with a 5 second duration', () {
    expect(AppSettings.defaults.crossfadeEnabled, isFalse);
    expect(AppSettings.defaults.crossfadeDurationSeconds, 5);
  });

  test('crossfade duration is clamped to 1-12 seconds', () {
    final settings = AppSettings.defaults.copyWith(
      crossfadeEnabled: true,
      crossfadeDurationSeconds: 0,
    );
    expect(settings.crossfadeDurationSeconds, 1);

    final long = AppSettings.defaults.copyWith(
      crossfadeDurationSeconds: 99,
    );
    expect(long.crossfadeDurationSeconds, 12);
  });
}
