import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/personalization/library_personalization_provider.dart';

class LibraryPersonalizationPage extends ConsumerWidget {
  const LibraryPersonalizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(libraryPersonalizationProvider);
    final notifier = ref.read(libraryPersonalizationProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Library Personalization')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Choose what appears in your Library',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Hide sections you do not use. Your choices are saved automatically.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                for (final section in librarySectionNames)
                  SwitchListTile.adaptive(
                    value: visible.contains(section),
                    title: Text(section),
                    onChanged: (_) => notifier.toggle(section),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: notifier.restoreDefaults,
              icon: const Icon(Icons.restore_rounded),
              label: const Text('Show all sections'),
            ),
          ),
        ],
      ),
    );
  }
}
