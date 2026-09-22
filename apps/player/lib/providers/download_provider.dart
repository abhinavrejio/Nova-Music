import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/current_song.dart';

/// Download support is not implemented yet, so this provider exposes real empty state.
final downloadProvider = Provider<List<CurrentSong>>((ref) => const []);
