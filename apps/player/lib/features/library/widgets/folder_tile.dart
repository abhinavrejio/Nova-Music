import 'package:flutter/material.dart';

class FolderTile extends StatelessWidget {
  const FolderTile({
    super.key,
    required this.path,
    this.songCount = 0,
    this.onTap,
    this.onDelete,
  });

  final String path;
  final int songCount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(
        path,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "$songCount songs",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onDelete == null
          ? const Icon(Icons.chevron_right)
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
      onTap: onTap,
    );
  }
}
