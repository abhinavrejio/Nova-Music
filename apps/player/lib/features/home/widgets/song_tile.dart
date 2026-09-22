import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/current_song.dart';
import '../../../models/song.dart';
import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/playback/current_song_provider.dart';
import '../../../providers/playback/queue_index_provider.dart';
import '../../../providers/playback/queue_provider.dart';
import '../../player/player_page.dart';

class SongTile extends ConsumerWidget {
  final Song song;
  final List<CurrentSong> songs;
  final int index;

  const SongTile({
    super.key,
    required this.song,
    this.songs = const [],
    this.index = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = CurrentSong(
      path: song.filePath.isEmpty ? song.title : song.filePath,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
    );

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          child: Icon(Icons.music_note),
        ),
        title: Text(song.title),
        subtitle: Text('${song.artist} • ${song.album}'),
        trailing: const Icon(Icons.more_vert),
        onTap: () async {
          ref.read(queueProvider.notifier).setQueue(songs);
          ref.read(queueIndexProvider.notifier).setIndex(index);
          ref.read(currentSongProvider.notifier).setSong(currentSong);

          if (currentSong.path.isNotEmpty) {
            await ref.read(audioPlayerProvider).openFile(currentSong.path);
          }

          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PlayerPage(),
              ),
            );
          }
        },
      ),
    );
  }
}