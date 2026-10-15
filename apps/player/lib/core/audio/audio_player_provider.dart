import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_controller.dart';
import 'audio_state.dart';

final audioControllerProvider =
    NotifierProvider<AudioController, AudioState>(
  AudioController.new,
);