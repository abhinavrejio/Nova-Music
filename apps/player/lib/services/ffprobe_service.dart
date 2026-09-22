import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class FFprobeService {
  static const String _defaultWindowsPath =
      r'C:\Users\rejik\AppData\Local\Microsoft\WinGet\Links\ffprobe.exe';

  String _resolveExecutable() {
    final configured = File(_defaultWindowsPath);
    if (configured.existsSync()) {
      return _defaultWindowsPath;
    }

    if (Platform.isWindows) {
      return 'ffprobe.exe';
    }

    return 'ffprobe';
  }

  Future<Map<String, dynamic>> read(String filePath) async {
    final executable = _resolveExecutable();

    try {
      final process = await Process.start(
        executable,
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

      final stdoutBytes = await process.stdout.expand((e) => e).toList();
      final stderrBytes = await process.stderr.expand((e) => e).toList();
      final exitCode = await process.exitCode;

      if (exitCode != 0) {
        final message = utf8.decode(stderrBytes);
        throw Exception(message.isNotEmpty ? message : 'ffprobe failed');
      }

      final jsonString = utf8.decode(stdoutBytes);
      debugPrint('JSON:');
      debugPrint(jsonString);

      final json = jsonDecode(jsonString);
      if (json is! Map<String, dynamic>) {
        return <String, dynamic>{};
      }

      return json;
    } on ProcessException catch (error) {
      debugPrint('FFprobe unavailable: ${error.message}');
      return const <String, dynamic>{};
    }
  }
}