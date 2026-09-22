import 'package:flutter/material.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.title,
    required this.songCount,
    this.onTap,
    this.onRename,
    this.onDelete,
  });

  final String title;
  final int songCount;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final seed = title.codeUnits.fold<int>(0, (sum, value) => sum + value);
    final first = HSVColor.fromAHSV(1, (seed * 37) % 360, 0.58, 0.92).toColor();
    final second = HSVColor.fromAHSV(1, (seed * 37 + 58) % 360, 0.48, 0.72).toColor();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [first, second]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 54,
          height: 54,
          child: Icon(Icons.queue_music_rounded, color: Colors.white),
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$songCount ${songCount == 1 ? 'song' : 'songs'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Rename playlist',
            child: IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: onRename,
            ),
          ),
          Tooltip(
            message: 'Delete playlist',
            child: IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
