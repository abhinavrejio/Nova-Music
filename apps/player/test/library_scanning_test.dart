import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:player/services/music_scanner.dart';

void main() {
  test('MusicScanner finds supported audio files in a directory tree', () async {
    final tempDir = await Directory.systemTemp.createTemp('music_scan_test');

    final mp3 = File('${tempDir.path}${Platform.pathSeparator}track1.mp3');
    final wav = File('${tempDir.path}${Platform.pathSeparator}nested${Platform.pathSeparator}track2.wav');
    final txt = File('${tempDir.path}${Platform.pathSeparator}notes.txt');

    await Directory('${tempDir.path}${Platform.pathSeparator}nested').create(recursive: true);
    await mp3.writeAsString('audio');
    await wav.writeAsString('audio');
    await txt.writeAsString('text');

    final scanner = MusicScanner();
    final files = await scanner.scanFolder(tempDir.path);

    expect(files.map((f) => f.path).toSet(), {
      mp3.path,
      wav.path,
    });

    await tempDir.delete(recursive: true);
  });
}
