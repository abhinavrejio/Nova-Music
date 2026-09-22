import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/colors.dart';
import '../../../models/album.dart';
import '../../../models/current_song.dart';
import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/playback/current_song_provider.dart';
import '../../../providers/playback/queue_index_provider.dart';
import '../../../providers/playback/queue_provider.dart';
import '../../player/player_page.dart';

class RecentAlbumCard extends ConsumerWidget {
  final Album album;
  final List<CurrentSong> songs;

  const RecentAlbumCard({
    super.key,
    required this.album,
    this.songs = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
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
        child: Container(
          width: 130,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: album.artworkUrl.isEmpty
                        ? Container(
                            color: AppColors.primary,
                            child: const Center(
                              child: Icon(
                                Icons.album,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                          )
                        : Image.network(
                            album.artworkUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  album.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  album.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}