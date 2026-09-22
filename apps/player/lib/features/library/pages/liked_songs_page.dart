import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/library/liked_songs_provider.dart';
import 'collection_songs_page.dart';

class LikedSongsPage extends ConsumerWidget {
  const LikedSongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CollectionSongsPage(
      title: 'Liked Songs',
      songs: ref.watch(likedSongsProvider),
      emptyMessage: 'No liked songs.',
    );
  }
}