enum HomeSection {
  continueListening(
    'Continue Listening',
  ),
  quickCollections(
    'Quick Collections',
  ),
  recentlyPlayed(
    'Recently Played',
  ),
  albums(
    'Albums',
  ),
  artists(
    'Artists',
  ),
  playlists(
    'Playlists',
  ),
  genres(
    'Genres',
  ),
  favorites(
    'Favorites',
  ),
  downloads(
    'Downloads',
  );

  const HomeSection(this.title);

  final String title;
}