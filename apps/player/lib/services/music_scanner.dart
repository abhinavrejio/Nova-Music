import 'dart:io';

class MusicScanner {
  static const _extensions = {
    '.mp3',
    '.m4a',
    '.aac',
    '.flac',
    '.wav',
    '.ogg',
    '.opus',
  };

  Future<List<File>> scanFolder(String folderPath) async {
    final directory = Directory(folderPath);

    if (!await directory.exists()) {
      return [];
    }

    final files = <File>[];

    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;

      final extension =
          entity.path.substring(entity.path.lastIndexOf('.')).toLowerCase();

      if (_extensions.contains(extension)) {
        files.add(entity);
      }
    }

    files.sort(
      (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()),
    );

    return files;
  }
}