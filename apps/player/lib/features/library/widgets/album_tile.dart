import 'package:flutter/material.dart';

class AlbumTile extends StatelessWidget {
  const AlbumTile({
    super.key,
    required this.title,
    required this.artist,
    this.artwork,
    this.onTap,
  });

  final String title;
  final String artist;
  final Widget? artwork;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 48,
          child: artwork ??
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Icon(Icons.album, color: Colors.white),
              ),
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
