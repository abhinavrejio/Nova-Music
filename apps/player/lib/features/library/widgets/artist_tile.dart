import 'package:flutter/material.dart';

class ArtistTile extends StatelessWidget {
  const ArtistTile({
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
        child: Icon(Icons.person),
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
