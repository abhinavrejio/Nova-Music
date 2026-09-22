import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/current_song.dart';
import '../../../providers/playlists/playlist_provider.dart';

Future<void> showCollectionPlaylistPicker(
  BuildContext context,
  WidgetRef ref,
  List<CurrentSong> songs,
) async {
  if (songs.isEmpty) return;
  final playlists = ref.read(playlistProvider);
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: playlists.isEmpty
          ? const Padding(padding: EdgeInsets.all(24), child: Text('No playlists available.'))
          : ListView(
              shrinkWrap: true,
              children: playlists.map((playlist) {
                return ListTile(
                  leading: const Icon(Icons.queue_music_rounded),
                  title: Text(playlist.name),
                  onTap: () async {
                    for (final song in songs) {
                      await ref.read(playlistProvider.notifier).addSong(playlist.id, song.path);
                    }
                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  },
                );
              }).toList(),
            ),
    ),
  );
}

String formatCollectionDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
