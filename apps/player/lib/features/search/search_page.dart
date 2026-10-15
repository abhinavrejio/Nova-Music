import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/current_song.dart';
import '../../models/playlist.dart';
import 'music_service.dart';
import 'search_service_preferences.dart';
import '../../providers/audio/audio_player_provider.dart';
import '../../providers/library/library_provider.dart';
import '../../providers/playback/current_song_provider.dart';
import '../../providers/playback/queue_index_provider.dart';
import '../../providers/playback/queue_provider.dart';
import '../../providers/playlists/playlist_provider.dart';
import '../../providers/settings_provider.dart';
import '../player/player_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  int _searchRequestId = 0;
  List<MusicSearchResult> _remoteResults = const [];
  bool _remoteSearchLoading = false;
  String? _remoteSearchError;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(libraryProvider);
    final playlists = ref.watch(playlistProvider);
    final settings = ref.watch(settingsProvider);
    final enabledServices = ref.watch(searchServicePreferencesProvider);
    final catalogServices = ref.watch(musicCatalogServicesProvider);
    final query = _searchController.text.trim().toLowerCase();

    final filteredSongs = settings.searchShowSongs
        ? songs.where((song) {
            if (query.isEmpty) return true;
            final text = [
              song.title,
              song.artist,
              song.album,
            ].join(' ').toLowerCase();
            return text.contains(query);
          }).toList()
        : <CurrentSong>[];

    final filteredPlaylists = settings.searchShowPlaylists
        ? playlists.where((playlist) {
            if (query.isEmpty) return true;
            return playlist.name.toLowerCase().contains(query);
          }).toList()
        : <Playlist>[];

    final theme = Theme.of(context);
    final resultsCount =
        filteredSongs.length + filteredPlaylists.length + _remoteResults.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 30, 32, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: .14,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.6,
                              ),
                            ),
                            Text(
                              'Browse your library',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        Text(
                          '$resultsCount ${resultsCount == 1 ? 'result' : 'results'}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: settings.liquidGlass
                              ? settings.glassBlurSigma
                              : 0,
                          sigmaY: settings.liquidGlass
                              ? settings.glassBlurSigma
                              : 0,
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText:
                                'Search songs, artists, albums, or playlists',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                      _scheduleRemoteSearch(
                                        '',
                                        enabledServices,
                                        catalogServices,
                                      );
                                    },
                                  ),
                            filled: true,
                            fillColor: theme.colorScheme.surface.withValues(
                              alpha: settings.liquidGlass
                                  ? settings.glassSurfaceOpacity
                                  : .94,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: .08,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: .7,
                                ),
                                width: 1.4,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                            _scheduleRemoteSearch(
                              value,
                              enabledServices,
                              catalogServices,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Search services',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final service in catalogServices)
                        FilterChip(
                          label: Text(
                            '${_serviceName(service.status.service)} · ${_serviceStateLabel(service.status.connection)}',
                          ),
                          selected: enabledServices.contains(
                            service.status.service,
                          ),
                          onSelected:
                              service.status.connection ==
                                  MusicServiceConnection.unsupported
                              ? null
                              : (selected) {
                                  final nextServices = {...enabledServices};
                                  if (selected) {
                                    nextServices.add(service.status.service);
                                  } else {
                                    nextServices.remove(service.status.service);
                                  }
                                  ref
                                      .read(
                                        searchServicePreferencesProvider
                                            .notifier,
                                      )
                                      .setEnabled(
                                        service.status.service,
                                        selected,
                                      );
                                  _scheduleRemoteSearch(
                                    _searchController.text,
                                    nextServices,
                                    catalogServices,
                                  );
                                },
                          tooltip: service.status.message,
                        ),
                    ],
                  ),
                  if (_remoteSearchError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _remoteSearchError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: [
                      _SearchFilterChip(
                        icon: Icons.music_note_rounded,
                        label: 'Songs',
                        count: filteredSongs.length,
                      ),
                      _SearchFilterChip(
                        icon: Icons.queue_music_rounded,
                        label: 'Playlists',
                        count: filteredPlaylists.length,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child:
                        resultsCount == 0 &&
                            _remoteResults.isEmpty &&
                            !_remoteSearchLoading
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 42,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: .7),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  query.isEmpty
                                      ? 'Your library is empty'
                                      : 'No matches found',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  query.isEmpty
                                      ? 'Add music to your library to start browsing.'
                                      : 'Try another song, artist, album, or playlist.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            children: [
                              if (filteredSongs.isNotEmpty) ...[
                                _SearchSectionHeading(
                                  title: 'Songs',
                                  count: filteredSongs.length,
                                ),
                                const SizedBox(height: 10),
                                for (final song in filteredSongs)
                                  _SongResultTile(
                                    song: song,
                                    queue: filteredSongs,
                                  ),
                                const SizedBox(height: 22),
                              ],
                              if (filteredPlaylists.isNotEmpty) ...[
                                _SearchSectionHeading(
                                  title: 'Playlists',
                                  count: filteredPlaylists.length,
                                ),
                                const SizedBox(height: 10),
                                for (final playlist in filteredPlaylists)
                                  _PlaylistResultTile(playlist: playlist),
                              ],
                              if (_remoteSearchLoading)
                                const Padding(
                                  padding: EdgeInsets.all(18),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (_remoteResults.isNotEmpty) ...[
                                _SearchSectionHeading(
                                  title: 'Streaming services',
                                  count: _remoteResults.length,
                                ),
                                const SizedBox(height: 10),
                                for (final result in _remoteResults)
                                  _RemoteSearchResultTile(result: result),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _scheduleRemoteSearch(
    String rawQuery,
    Set<MusicServiceId> enabled,
    List<MusicCatalogService> services,
  ) {
    final requestId = ++_searchRequestId;
    _searchDebounce?.cancel();
    final query = rawQuery.trim();
    if (query.isEmpty) {
      setState(() {
        _remoteResults = const [];
        _remoteSearchError = null;
        _remoteSearchLoading = false;
      });
      return;
    }

    setState(() {
      _remoteResults = const [];
      _remoteSearchError = null;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _remoteSearchLoading = true;
        _remoteSearchError = null;
      });
      final searchable = services.where(
        (service) =>
            enabled.contains(service.status.service) &&
            (service.status.connection == MusicServiceConnection.connected ||
                service.status.connection ==
                    MusicServiceConnection.catalogReady),
      );
      var hadError = false;
      final results = await Future.wait(
        searchable.map((service) async {
          try {
            return await service.search(query);
          } catch (_) {
            hadError = true;
            return const <MusicSearchResult>[];
          }
        }),
      );
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _remoteResults = results.expand((items) => items).toList();
        _remoteSearchLoading = false;
        _remoteSearchError = hadError
            ? 'One or more streaming services could not be searched.'
            : null;
      });
    });
  }

  String _serviceName(MusicServiceId service) => switch (service) {
    MusicServiceId.appleMusic => 'Apple Music',
    MusicServiceId.spotify => 'Spotify',
    MusicServiceId.youtubeMusic => 'YouTube Music',
  };

  String _serviceStateLabel(MusicServiceConnection state) => switch (state) {
    MusicServiceConnection.connected => 'connected',
    MusicServiceConnection.catalogReady => 'catalog ready',
    MusicServiceConnection.needsSetup => 'set up',
    MusicServiceConnection.disconnected => 'disconnected',
    MusicServiceConnection.unsupported => 'unsupported',
  };
}

class _SongResultTile extends ConsumerWidget {
  const _SongResultTile({required this.song, required this.queue});

  final CurrentSong song;
  final List<CurrentSong> queue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: .58),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () async {
          final selectedIndex = queue.indexWhere(
            (queuedSong) => queuedSong.path == song.path,
          );
          final queueIndex = selectedIndex >= 0 ? selectedIndex : 0;

          ref.read(queueProvider.notifier).setQueue(queue);
          ref.read(queueIndexProvider.notifier).setIndex(queueIndex);
          ref.read(currentSongProvider.notifier).setSong(song);

          final filePath = song.path;
          if (filePath.isNotEmpty && File(filePath).existsSync()) {
            await ref.read(audioPlayerProvider).openFile(filePath);
          }

          if (context.mounted) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const PlayerPage()));
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: .06),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: song.artwork == null
                    ? Icon(
                        Icons.music_note_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                      )
                    : Image.memory(song.artwork!, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${song.artist} • ${song.album}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDuration(song.duration),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _PlaylistResultTile extends StatelessWidget {
  const _PlaylistResultTile({required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.queue_music_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${playlist.songCount} songs',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoteSearchResultTile extends StatelessWidget {
  const _RemoteSearchResultTile({required this.result});

  final MusicSearchResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: .58),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: result.artworkUrl == null
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.music_note_rounded),
                )
              : Image.network(
                  result.artworkUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.music_note_rounded),
                  ),
                ),
        ),
        title: Text(result.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${_serviceDisplayName(result.service)} · ${result.artist}${result.subtitle.isEmpty ? '' : ' · ${result.subtitle}'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Open ${result.service.name} result',
          icon: const Icon(Icons.open_in_new_rounded),
          onPressed: result.url.isEmpty
              ? null
              : () => launchUrl(
                  Uri.parse(result.url),
                  mode: LaunchMode.externalApplication,
                ),
        ),
      ),
    );
  }
}

String _serviceDisplayName(MusicServiceId service) => switch (service) {
  MusicServiceId.appleMusic => 'Apple Music',
  MusicServiceId.spotify => 'Spotify',
  MusicServiceId.youtubeMusic => 'YouTube Music',
};

class _SearchSectionHeading extends StatelessWidget {
  const _SearchSectionHeading({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(width: 8),
      Text(
        '$count',
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}

class _SearchFilterChip extends StatelessWidget {
  const _SearchFilterChip({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
    label: Text('$label · $count'),
    side: BorderSide(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .08),
    ),
    backgroundColor: Theme.of(context).colorScheme.surface
        .withValues(alpha: .5),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
  );
}
