import 'package:flutter_test/flutter_test.dart';
import 'package:player/models/current_song.dart';
import 'package:player/providers/playback/queue_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('Queue provider removes one song and ignores invalid indexes', () {
    const songs = [
      CurrentSong(
        path: '/music/one.mp3',
        title: 'One',
        artist: 'Artist',
        album: 'Album',
        duration: Duration(minutes: 3),
      ),
      CurrentSong(
        path: '/music/two.mp3',
        title: 'Two',
        artist: 'Artist',
        album: 'Album',
        duration: Duration(minutes: 3),
      ),
    ];
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(queueProvider.notifier);
    notifier.setQueue(songs);
    notifier.removeAt(0);
    expect(container.read(queueProvider), [songs[1]]);

    notifier.removeAt(-1);
    notifier.removeAt(2);
    expect(container.read(queueProvider), [songs[1]]);

    notifier.setQueue(songs);
    notifier.reorder(0, 2);
    expect(container.read(queueProvider), [songs[1], songs[0]]);

    notifier.reorder(-1, 0);
    notifier.reorder(0, 4);
    expect(container.read(queueProvider), [songs[1], songs[0]]);

    notifier.reorderItem(1, 0);
    expect(container.read(queueProvider), [songs[0], songs[1]]);
  });
}