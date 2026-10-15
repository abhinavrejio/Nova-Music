import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/lyrics.dart';
import '../../services/lyrics_service.dart';

typedef LyricsQuery = ({
  String title,
  String artist,
  String trackId,
  String? album,
  Duration? duration,
});

final lyricsProvider = FutureProvider.autoDispose.family<Lyrics?, LyricsQuery>((
  ref,
  query,
) {
  return LyricsService.instance.loadLyrics(
    title: query.title,
    artist: query.artist,
    trackId: query.trackId,
    album: query.album,
    duration: query.duration,
  );
});
