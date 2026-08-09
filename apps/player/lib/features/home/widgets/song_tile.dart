import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
  final String title;
  final String artist;

  const SongTile({
    super.key,
    required this.title,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.music_note),
      title: Text(title),
      subtitle: Text(artist),
      trailing: const Icon(Icons.more_vert),
    );
  }
}git add .