import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/library/library_provider.dart';
import '../../../providers/recent_provider.dart';
import 'continue_listening_card.dart';
import 'section_header.dart';

class ContinueListeningSection extends ConsumerWidget {
  const ContinueListeningSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final recent = ref.watch(recentlyPlayedSongsProvider);

    final songs = recent.isNotEmpty ? recent : library;

    if (songs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Continue Listening",
          subtitle: "Resume where you left off",
        ),

        const SizedBox(height: 20),

        ContinueListeningCard(
          songs: songs,
        ),
      ],
    );
  }
}