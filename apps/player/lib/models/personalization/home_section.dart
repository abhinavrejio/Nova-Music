enum HomeSection {
  continueListening(
    "Continue Listening",
    true,
  ),
  quickCollections(
    "Quick Collections",
    true,
  ),
  recentlyPlayed(
    "Recently Played",
    true,
  ),
  albums(
    "Albums",
    true,
  ),
  artists(
    "Artists",
    true,
  ),
  playlists(
    "Playlists",
    true,
  ),
  genres(
    "Genres",
    true,
  ),
  favorites(
    "Favorites",
    true,
  ),
  downloads(
    "Downloads",
    true,
  );

  const HomeSection(
    this.title,
    this.enabled,
  );

  final String title;
  final bool enabled;
}