import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio_player_provider.dart';
import '../../providers/current_song_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/library_folder_provider.dart';
import '../../providers/local_music_provider.dart';

import '../player/player_page.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(libraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Library (${songs.length})"),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: "Add Music Folder",
            onPressed: () async {
              debugPrint("Folder button pressed");

              final picker = ref.read(localMusicProvider);

              final folder = await picker.pickMusicFolder();

              if (folder == null) {
                return;
              }

              // Save the folder permanently.
              await ref
                  .read(libraryFolderProvider.notifier)
                  .addFolder(folder);

              // Scan only this folder.
              await ref
                  .read(libraryProvider.notifier)
                  .scanFolder(folder);
            },
          ),
        ],
      ),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                "No music found.\n\nClick the folder icon above to add a music folder.",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];

                return ListTile(
                  leading: song.artwork != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            song.artwork!,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.music_note),
                        ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () async {
                    ref.read(currentSongProvider.notifier).setSong(song);

                    await ref
                        .read(audioPlayerProvider)
                        .openFile(song.path);

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PlayerPage(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}