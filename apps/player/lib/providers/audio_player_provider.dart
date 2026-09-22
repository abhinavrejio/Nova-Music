import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio_player_service.dart';

final _audioPlayerService = AudioPlayerService();

final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  return _audioPlayerService;
});