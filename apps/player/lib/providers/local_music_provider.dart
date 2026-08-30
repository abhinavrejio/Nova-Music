import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_music_service.dart';

final localMusicProvider = Provider<LocalMusicService>((ref) {
  return LocalMusicService();
});