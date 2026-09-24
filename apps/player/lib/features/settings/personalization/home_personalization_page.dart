import 'package:flutter/material.dart';

class HomePersonalizationPage extends StatefulWidget {
  const HomePersonalizationPage({super.key});

  @override
  State<HomePersonalizationPage> createState() =>
      _HomePersonalizationPageState();
}

class _HomePersonalizationPageState
    extends State<HomePersonalizationPage> {
  static const List<String> _defaultSections = [
    'Continue Listening',
    'Quick Collections',
    'Recently Played',
    'Albums',
    'Artists',
    'Playlists',
    'Genres',
    'Favorites',
    'Downloads',
  ];

  late List<String> sections;

  @override
  void initState() {
    super.initState();
    sections = List.from(_defaultSections);
  }

  void _restoreDefaults() {
    setState(() {
      sections = List.from(_defaultSections);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Personalization'),
      ),
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
              'This order will be reflected on your Home page.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ReorderableListView.builder(
                itemCount: sections.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex--;
                    }

                    final item = sections.removeAt(oldIndex);
                    sections.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  return Card(
                    key: ValueKey(sections[index]),
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.drag_indicator_rounded),
                      title: Text(
                        sections[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Drag to reorder this section',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _restoreDefaults,
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