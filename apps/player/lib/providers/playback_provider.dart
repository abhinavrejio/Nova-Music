import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_player_provider.dart';

final positionProvider = StreamProvider<Duration>((ref) {
  final player = ref.watch(audioPlayerProvider).player;
  return player.stream.position;
});

final durationProvider = StreamProvider<Duration>((ref) {
  final player = ref.watch(audioPlayerProvider).player;
  return player.stream.duration;
});

final bufferedProvider = StreamProvider<Duration>((ref) {
  final player = ref.watch(audioPlayerProvider).player;
  return player.stream.buffer;
});

final playingProvider = StreamProvider<bool>((ref) {
  final player = ref.watch(audioPlayerProvider).player;
  return player.stream.playing;
});