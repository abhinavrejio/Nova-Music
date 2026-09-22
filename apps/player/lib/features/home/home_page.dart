import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../providers/library/library_provider.dart';
import '../../providers/most_played_provider.dart';
import '../../providers/recent_provider.dart';
import 'widgets/continue_listening_card.dart';
import 'widgets/home_song_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final recentlyPlayed = ref.watch(recentlyPlayedSongsProvider);
    final mostPlayed = ref.watch(mostPlayedSongsProvider);
    final heroQueue = recentlyPlayed.isNotEmpty ? recentlyPlayed : library;
    final latest = library.where((song) => song.importedAt != null).toList()
      ..sort((a, b) => b.importedAt!.compareTo(a.importedAt!));

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: library.isEmpty
                ? const _HomeEmptyState()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _NovaGreeting(),
                      const SizedBox(height: 28),
                      ContinueListeningCard(songs: heroQueue),
                      const SizedBox(height: 34),
                      _SectionHeading(eyebrow: 'YOUR SIGNAL', title: 'Picked for this moment', accent: AppColors.secondary),
                      const SizedBox(height: 14),
                      _SongRail(songs: mostPlayed.isNotEmpty ? mostPlayed : library),
                      const SizedBox(height: 34),
                      _SectionHeading(eyebrow: 'FRESH FREQUENCIES', title: 'New in your orbit', accent: AppColors.tertiary),
                      const SizedBox(height: 14),
                      _SongRail(songs: latest.isNotEmpty ? latest : library),
                      if (recentlyPlayed.isNotEmpty) ...[
                        const SizedBox(height: 34),
                        _SectionHeading(eyebrow: 'KEEP THE THREAD', title: 'Recently played', accent: AppColors.primary),
                        const SizedBox(height: 14),
                        _SongRail(songs: recentlyPlayed),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _NovaGreeting extends StatelessWidget {
  const _NovaGreeting();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NOVA / HOME', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 2, color: AppColors.primary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(greeting, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Your sound, in motion.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        const Icon(Icons.wb_sunny_outlined, color: AppColors.tertiary, size: 30),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.eyebrow, required this.title, required this.accent});

  final String eyebrow;
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 5, height: 36, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8))),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow, style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.6, color: accent, fontWeight: FontWeight.w800)),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }
}

class _SongRail extends StatelessWidget {
  const _SongRail({required this.songs});

  final List songs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 222,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, index) => HomeSongCard(song: songs[index], queue: songs.cast()),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 56, color: AppColors.primary),
            const SizedBox(height: 18),
            Text('Your orbit is quiet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Add a library folder to begin your Nova journey.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
