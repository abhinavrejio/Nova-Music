@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Container(
    width: 130,
    margin: const EdgeInsets.only(right: 12),

    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: Padding(
      padding: const EdgeInsets.all(12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),

              child: album.artworkUrl.isEmpty
                  ? Container(
                      color: AppColors.primary,
                      child: const Center(
                        child: Icon(
                          Icons.album,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    )
                  : Image.network(
                      album.artworkUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            album.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            album.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}