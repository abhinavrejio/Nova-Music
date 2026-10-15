import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_player_provider.dart';

final positionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerProvider).positionStream;
});

final durationProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerProvider).durationStream;
});

final bufferedProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerProvider).bufferStream;
});

final playingProvider = StreamProvider<bool>((ref) {
  return ref.watch(audioPlayerProvider).playingStream;
});