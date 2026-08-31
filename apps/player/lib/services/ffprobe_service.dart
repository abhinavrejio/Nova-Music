import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class FFprobeService {
  static const String ffprobePath =
      r'C:\Users\rejik\AppData\Local\Microsoft\WinGet\Links\ffprobe.exe';

  Future<Map<String, dynamic>> read(String filePath) async {
    final process = await Process.start(
      ffprobePath,
      [
        '-v',
        'quiet',
        '-print_format',
        'json',
        '-show_format',
        '-show_streams',
        filePath,
      ],
    );

    // Read raw bytes
    final stdoutBytes = await process.stdout.expand((e) => e).toList();
    final stderrBytes = await process.stderr.expand((e) => e).toList();

    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      throw Exception(utf8.decode(stderrBytes));
    }

    // Decode explicitly as UTF-8
    final jsonString = utf8.decode(stdoutBytes);

    debugPrint("JSON:");
    debugPrint(jsonString);

    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}