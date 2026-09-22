import 'package:flutter/material.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.title,
    required this.songCount,
    required this.onTap,
  });

  final String title;
  final int songCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.queue_music),
      ),
      title: Text(title),
      subtitle: Text("$songCount songs"),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}