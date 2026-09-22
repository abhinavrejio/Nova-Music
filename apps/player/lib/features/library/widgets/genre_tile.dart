import 'package:flutter/material.dart';

class GenreTile extends StatelessWidget {
  const GenreTile({
    super.key,
    required this.name,
    this.songCount = 0,
    this.onTap,
  });

  final String name;
  final int songCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.category),
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "$songCount songs",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
