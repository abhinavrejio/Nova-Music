import 'package:flutter/material.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.title,
    required this.songCount,
    this.onTap,
    this.onRename,
    this.onDelete,
    this.onPin,
    this.isPinned = false,
  });

  final String title;
  final int songCount;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    final seed = title.codeUnits.fold<int>(0, (sum, value) => sum + value);
    final first = HSVColor.fromAHSV(1, (seed * 37) % 360, 0.58, 0.92).toColor();
    final second = HSVColor.fromAHSV(
      1,
      (seed * 37 + 58) % 360,
      0.48,
      0.72,
    ).toColor();

    void performAction(String action) {
      switch (action) {
        case 'pin':
          onPin?.call();
          break;
        case 'rename':
          onRename?.call();
          break;
        case 'delete':
          onDelete?.call();
          break;
      }
    }

    final menuItems = <PopupMenuEntry<String>>[
      PopupMenuItem(
        value: 'pin',
        child: Text(isPinned ? 'Unpin from sidebar' : 'Pin to sidebar'),
      ),
      const PopupMenuItem(value: 'rename', child: Text('Rename')),
      const PopupMenuItem(value: 'delete', child: Text('Delete')),
    ];

    return GestureDetector(
      onSecondaryTapDown: (details) async {
        final overlay =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final point = details.globalPosition;
        final menuPosition = RelativeRect.fromRect(
          Rect.fromPoints(point, point),
          Offset.zero & overlay.size,
        );
        final action = await showMenu<String>(
          context: context,
          position: menuPosition,
          items: menuItems,
        );
        if (action != null && context.mounted) performAction(action);
      },
      child: ListTile(
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
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '$songCount ${songCount == 1 ? 'song' : 'songs'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Playlist options',
          onSelected: performAction,
          itemBuilder: (_) => menuItems,
          icon: const Icon(Icons.more_horiz_rounded),
        ),
        onTap: onTap,
      ),
    );
  }
}
