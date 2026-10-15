import 'package:flutter/material.dart';

import '../../../models/personalization/home_section.dart';

import '../widgets/continue_listening_section.dart';
import '../widgets/collections_section.dart';
import '../widgets/recently_played_section.dart';
import '../widgets/album_section.dart';
import '../widgets/artists_section.dart';

class HomeSectionBuilder {
  static Widget build(HomeSection section) {
    switch (section.type) {
      case HomeSectionType.continueListening:
        return const ContinueListeningSection();

      case HomeSectionType.quickCollections:
        return const CollectionsSection();

      case HomeSectionType.recentlyPlayed:
        return const RecentlyPlayedSection();

      case HomeSectionType.albums:
        return const AlbumsSection();

      case HomeSectionType.artists:
        return const ArtistsSection();

      case HomeSectionType.playlists:
        return const SizedBox.shrink();

      case HomeSectionType.genres:
        return const SizedBox.shrink();

      case HomeSectionType.favorites:
        return const SizedBox.shrink();

      case HomeSectionType.downloads:
        return const SizedBox.shrink();
    }
  }
}