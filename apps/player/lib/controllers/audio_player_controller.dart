import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/song.dart';
import '../providers/audio/audio_player_provider.dart';

class AudioPlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const AudioPlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioPlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return AudioPlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class AudioPlayerController extends StateNotifier<AudioPlayerState> {
  AudioPlayerController(this.ref)
      : super(const AudioPlayerState()) {
    _listen();
  }

  final Ref ref;

  StreamSubscription? _playingSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;

  void _listen() {
    final player = ref.read(audioPlayerProvider);

    _playingSub = player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    _positionSub = player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _durationSub = player.durationStream.listen((duration) {
      state = state.copyWith(duration: duration);
    });
  }

  Future<void> playSong(
    Song song,
    String path,
  ) async {
    state = state.copyWith(currentSong: song);

    await ref.read(audioPlayerProvider).openFile(path);
  }

  Future<void> togglePlayPause() async {
    await ref.read(audioPlayerProvider).togglePlayPause();
  }

  Future<void> seek(Duration position) async {
    await ref.read(audioPlayerProvider).seek(position);
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }
}

final audioPlayerControllerProvider =
    StateNotifierProvider<AudioPlayerController, AudioPlayerState>((ref) {
  return AudioPlayerController(ref);
});