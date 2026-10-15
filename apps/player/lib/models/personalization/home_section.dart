enum HomeSectionType {
  continueListening,
  quickCollections,
  recentlyPlayed,
  albums,
  artists,
  playlists,
  genres,
  favorites,
  downloads,
}

class HomeSection {
  const HomeSection({
    required this.type,
    required this.title,
    this.visible = true,
  });

  final HomeSectionType type;
  final String title;
  final bool visible;

  HomeSection copyWith({
    bool? visible,
  }) {
    return HomeSection(
      type: type,
      title: title,
      visible: visible ?? this.visible,
    );
  }
}