import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class ArtworkService {
  static const String ffmpegPath =
      r'C:\Users\rejik\AppData\Local\Microsoft\WinGet\Links\ffmpeg.exe';

  Future<Uint8List?> extractArtwork(String filePath) async {
    final tempDir = Directory.systemTemp;
    final output =
        "${tempDir.path}\\album_art_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await Process.run(
      ffmpegPath,
      [
  "-y",
  "-i",
  filePath,
  "-an",
  "-frames:v",
  "1",
  "-update",
  "1",
  output,
],
    );

    debugPrint("Artwork Exit Code: ${result.exitCode}");
    debugPrint(result.stderr.toString());

    final file = File(output);

    if (!await file.exists()) {
      debugPrint("Artwork file not created.");
      return null;
    }

    final bytes = await file.readAsBytes();

    debugPrint("Artwork Bytes: ${bytes.length}");

    await file.delete();

    return bytes;
  }
}