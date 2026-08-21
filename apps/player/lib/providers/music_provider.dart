import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/music_repository.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return const MusicRepository();
});