import 'package:flutter/material.dart';

class PlaylistCard extends StatelessWidget {
  final String title;

  const PlaylistCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.queue_music),
        title: Text(title),
      ),
    );
  }
}