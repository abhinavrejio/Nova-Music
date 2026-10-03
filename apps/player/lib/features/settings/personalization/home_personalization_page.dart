import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/personalization/home_personalization_provider.dart';

class HomePersonalizationPage extends ConsumerWidget {
  const HomePersonalizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(homePersonalizationProvider);
    final notifier = ref.read(homePersonalizationProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Home Personalization')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customize your Home',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            Text(
              'Drag and drop sections to change their order. '
              'This order is saved and reflected on your Home page.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ReorderableListView.builder(
                itemCount: sections.length,
                onReorderItem: notifier.reorder,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return Card(
                    key: ValueKey(section.type),
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_indicator_rounded),
                      ),
                      title: Text(
                        section.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('Drag to reorder this section'),
                      trailing: Switch.adaptive(
                        value: section.visible,
                        onChanged: (_) => notifier.toggle(section.type),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: notifier.restoreDefaults,
                icon: const Icon(Icons.restore),
                label: const Text('Restore Defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
