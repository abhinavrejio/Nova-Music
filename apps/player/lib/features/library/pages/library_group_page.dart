import 'package:flutter/material.dart';

import '../../../models/current_song.dart';

class LibraryGroupPage extends StatelessWidget {
  const LibraryGroupPage({
    super.key,
    required this.title,
    required this.icon,
    required this.groups,
    required this.onGroupSelected,
  });

  final String title;
  final IconData icon;
  final Map<String, List<CurrentSong>> groups;
  final Widget Function(String name, List<CurrentSong> songs) onGroupSelected;

  @override
  Widget build(BuildContext context) {
    final entries = groups.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: entries.isEmpty
          ? Center(
              child: Text(
                'No $title found yet.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  leading: CircleAvatar(child: Icon(icon)),
                  title: Text(entry.key),
                  subtitle: Text('${entry.value.length} songs'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => onGroupSelected(entry.key, entry.value),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
