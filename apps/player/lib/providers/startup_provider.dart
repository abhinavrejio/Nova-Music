import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'library_provider.dart';

final startupProvider = FutureProvider<void>((ref) async {
  await ref.read(libraryProvider.notifier).rescanAll();
});