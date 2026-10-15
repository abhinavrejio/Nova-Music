# Verification record — 2026-10-14

Environment: Flutter 3.47.7, Dart 3.13.5, Windows 11 x64, Visual Studio Community 2026.

## Passing checks

- Focused regression suite: 28 tests passed. It covers LRCLIB word-timing parsing and line fallback, timestamp-driven karaoke highlighting, mini-player play/pause and open-player taps, crossfade scheduling and single-trigger behavior, fullscreen control-channel state, Adaptive Glass recommendation logic, UI-scale hit testing, resize behavior, crossfade settings, and the removal of keyboard shortcuts.
- Windows desktop build: `flutter build windows` succeeded from a short-path working copy and produced `build/windows/x64/runner/Release/player.exe`.

## Existing project failures

- `flutter analyze` exits non-zero because `test/last_played_track_test.dart` references `SettingsNotifier.setRestoreLastTrack` and `lastPlayedTrackStorageKey`, neither of which exists in this project. There is also one informational lint in `playback_controller_provider.dart` about repeated underscores.
- The full `flutter test` run has four failures: the Recently Played test records one event instead of two and then uses a disposed notifier; the home-page test times out in `pumpAndSettle`; the stale last-played-track test does not compile; and a navigation test expects a `NOVA` label that is absent.

The fullscreen test verifies the Now Playing button and method-channel enter/exit requests; the Windows native implementation compiles, but the OS window transition was not manually exercised. Crossfade verification covers controller handoff and single-trigger behavior; no audible playback hardware check was performed.
