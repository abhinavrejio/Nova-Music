import 'package:file_picker/file_picker.dart';

class LocalMusicService {
  Future<String?> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp3',
        'wav',
        'flac',
        'm4a',
        'aac',
        'ogg',
      ],
    );

    if (result == null) return null;

    return result.files.single.path;
  }

  Future<String?> pickMusicFolder() async {
    return await FilePicker.platform.getDirectoryPath();
  }
}