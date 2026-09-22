import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/colors.dart';
import '../../../models/current_song.dart';
import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/playback/current_song_provider.dart';
import '../../../providers/playback/queue_index_provider.dart';
import '../../../providers/playback/queue_provider.dart';
import '../../player/player_page.dart';

class PlaylistCard extends ConsumerWidget {
  final String title;
  final List<CurrentSong> songs;

  const PlaylistCard({
    super.key,
    required this.title,
    this.songs = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.queue_music,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Playlist',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: songs.isEmpty
            ? null
            : () async {
                final selectedSong = songs.first;
                ref.read(queueProvider.notifier).setQueue(songs);
                ref.read(queueIndexProvider.notifier).setIndex(0);
                ref.read(currentSongProvider.notifier).setSong(selectedSong);

                await ref.read(audioPlayerProvider).openFile(selectedSong.path);

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