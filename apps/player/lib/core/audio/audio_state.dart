enum PlaybackStatus {
  stopped,
  loading,
  playing,
  paused,
  completed,
}

class AudioState {
  const AudioState({
    this.status = PlaybackStatus.stopped,
    this.title = '',
    this.artist = '',
    this.album = '',
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isShuffleEnabled = false,
    this.repeatMode = 0,
  });

  final PlaybackStatus status;
  final String title;
  final String artist;
  final String album;

  final Duration position;
  final Duration duration;

  final double volume;

  final bool isShuffleEnabled;

  final int repeatMode;

  AudioState copyWith({
    PlaybackStatus? status,
    String? title,
    String? artist,
    String? album,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffleEnabled,
    int? repeatMode,
  }) {
    return AudioState(
      status: status ?? this.status,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffleEnabled:
          isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}