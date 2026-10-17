import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/genius_service.dart';
import '../../../services/lyrics_credentials_service.dart';

class GeniusDetailsButton extends StatelessWidget {
  const GeniusDetailsButton({
    super.key,
    required this.title,
    required this.artist,
  });

  final String title;
  final String artist;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Song details from Genius',
    visualDensity: VisualDensity.compact,
    onPressed: () => _openDetails(context),
    icon: const Icon(Icons.open_in_new_rounded, size: 18),
  );

  Future<void> _openDetails(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final token = await LyricsCredentialsService.instance.readGeniusToken();
    if (token == null || token.isEmpty) {
      final query = Uri.encodeQueryComponent('$title $artist');
      await launchUrl(Uri.parse('https://genius.com/search?q=$query'));
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'For in-app Genius details, add an API token in Settings.',
          ),
        ),
      );
      return;
    }

    final details = await GeniusService().findSong(
      accessToken: token,
      title: title,
      artist: artist,
    );
    if (!context.mounted) return;
    if (details == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Genius could not find this song.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.music_note_rounded),
        title: Text(details.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details.artist),
            if (details.album?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('Album  ·  ${details.album}'),
            ],
            if (details.releaseDate?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text('Released  ·  ${details.releaseDate}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              launchUrl(Uri.parse(details.url));
              Navigator.pop(dialogContext);
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open Genius'),
          ),
        ],
      ),
    );
  }
}
