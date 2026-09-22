import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/colors.dart';
import '../../../models/current_song.dart';
import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/playback/current_song_provider.dart';
import '../../../providers/playback/queue_index_provider.dart';
import '../../../providers/playback/queue_provider.dart';
import '../../player/player_page.dart';

class ContinueListeningCard extends ConsumerWidget {
  const ContinueListeningCard({
    super.key,
    this.songs = const [],
  });

  final List<CurrentSong> songs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredSong = songs.isNotEmpty ? songs.first : null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: featuredSong == null
            ? null
            : () async {
                ref.read(queueProvider.notifier).setQueue(songs);
                ref.read(queueIndexProvider.notifier).setIndex(0);
                ref.read(currentSongProvider.notifier).setSong(featuredSong);

                await ref.read(audioPlayerProvider).openFile(featuredSong.path);

                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PlayerPage(),
                    ),
                  );
                }
              },
        child: Container(
          height: 240,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.ink,
            image: featuredSong?.artwork == null
                ? null
                : DecorationImage(
                    image: MemoryImage(featuredSong!.artwork!),
                    fit: BoxFit.cover,
                    opacity: 0.34,
                  ),
            gradient: const LinearGradient(
              colors: [Color(0xCC0B1014), Color(0x992B4C4A), Color(0xCCFF6B5F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CONTINUE LISTENING', style: TextStyle(color: AppColors.secondary, letterSpacing: 1.8, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                featuredSong?.title ?? 'Nothing queued yet',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                featuredSong?.artist.isNotEmpty == true ? featuredSong!.artist : 'Choose a song to begin',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: featuredSong == null ? null : () async {
                  ref.read(queueProvider.notifier).setQueue(songs);
                  ref.read(queueIndexProvider.notifier).setIndex(0);
                  ref.read(currentSongProvider.notifier).setSong(featuredSong);
                  await ref.read(audioPlayerProvider).openFile(featuredSong.path);
                  if (context.mounted) Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerPage()));
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Resume'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}