import 'package:flutter/material.dart';

import '../../../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;

  const SongTile({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: const CircleAvatar(
        child: Icon(Icons.music_note),
      ),

      title: Text(song.title),

      subtitle: Text(
        '${song.artist} • ${song.album}',
      ),

      trailing: const Icon(Icons.more_vert),
    );
  }
}