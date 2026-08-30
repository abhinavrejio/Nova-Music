import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio_player_provider.dart';
import '../../providers/current_song_provider.dart';
import '../../repositories/library_repository.dart';
import '../player/player_page.dart';
import '../../providers/local_music_provider.dart';
import '../../services/library_builder.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = LibraryRepository.instance.songs;
    debugPrint("Library contains ${songs.length} songs");

    return Scaffold(
      appBar: AppBar(
  title: const Text("Library"),
  actions: [
  IconButton(
    icon: const Icon(Icons.folder_open),
    onPressed: () async {
      debugPrint("Folder button pressed");

      final picker = ref.read(localMusicProvider);

      final folder = await picker.pickMusicFolder();

      debugPrint("Folder: $folder");

      if (folder == null) return;

      await LibraryBuilder().buildLibrary(folder);

      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }
    },
  ), // <-- closes IconButton
],   // <-- closes actions list
),    // <-- closes AppBar

body: songs.isEmpty
          ? const Center(
              child: Text(
                "No songs imported.\nUse 'Pick & Play Song' first.",
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
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.music_note),
                        ),

                  title: Text(song.title),

                  subtitle: Text(song.artist),

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