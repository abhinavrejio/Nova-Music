import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/current_song.dart';
import '../../models/playlist.dart';
import 'music_catalog_providers.dart';
import 'music_service.dart';
import 'spotify_service.dart';
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
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
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
                      borderRadius: BorderRadius.circular(12),
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
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: .08,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                      ActionChip(
                        avatar: Icon(
                          Icons.login_rounded,
                          size: 17,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(
                          catalogServices
                                      .map((service) => service.status)
                                      .where(
                                        (status) =>
                                            status.service ==
                                            MusicServiceId.spotify,
                                      )
                                      .first
                                      .connection ==
                                  MusicServiceConnection.connected
                              ? 'Disconnect Spotify'
                              : 'Connect Spotify',
                        ),
                        onPressed: () async {
                          final connection = ref.read(
                            spotifyConnectionProvider.notifier,
                          );
                          final isConnected =
                              ref
                                  .read(musicCatalogServicesProvider)
                                  .map((service) => service.status)
                                  .where(
                                    (status) =>
                                        status.service ==
                                        MusicServiceId.spotify,
                                  )
                                  .first
                                  .connection ==
                              MusicServiceConnection.connected;
                          if (isConnected) {
                            await connection.disconnect();
                          } else {
                            await connection.connect();
                          }
                          final state = ref.read(spotifyConnectionProvider);
                          if (state.hasError && mounted) {
                            setState(() {
                              _remoteSearchError = state.error.toString();
                            });
                          } else if (mounted) {
                            setState(() {
                              _remoteSearchError = null;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (_searchController.text.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ActionChip(
                          avatar: const Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                          ),
                          label: const Text('Search YouTube Music externally'),
                          tooltip: 'YouTube Music has no supported public search API. This opens its website.',
                          onPressed: () => launchUrl(
                            Uri.https('music.youtube.com', '/search', {
                              'q': _searchController.text.trim(),
                            }),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ),
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
                  const _SpotifyRemotePlaybackPanel(),
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
      borderRadius: BorderRadius.circular(10),
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
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
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

class _RemoteSearchResultTile extends ConsumerWidget {
  const _RemoteSearchResultTile({required this.result});

  final MusicSearchResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: .58),
        borderRadius: BorderRadius.circular(10),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (result.service == MusicServiceId.spotify)
              IconButton(
                tooltip: 'Play on Spotify',
                icon: const Icon(Icons.play_arrow_rounded),
                onPressed: () async {
                  try {
                    await ref
                        .read(spotifyRemotePlaybackServiceProvider)
                        .playTrack(result.id);
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  }
                },
              ),
            IconButton(
              tooltip: 'Open ${result.service.name} result',
              icon: const Icon(Icons.open_in_new_rounded),
              onPressed: result.url.isEmpty
                  ? null
                  : () => launchUrl(
                      Uri.parse(result.url),
                      mode: LaunchMode.externalApplication,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotifyRemotePlaybackPanel extends ConsumerStatefulWidget {
  const _SpotifyRemotePlaybackPanel();

  @override
  ConsumerState<_SpotifyRemotePlaybackPanel> createState() =>
      _SpotifyRemotePlaybackPanelState();
}

class _SpotifyRemotePlaybackPanelState
    extends ConsumerState<_SpotifyRemotePlaybackPanel> {
  Timer? _pollTimer;
  List<SpotifyPlaybackDevice> _devices = const [];
  SpotifyPlaybackSnapshot? _snapshot;
  String? _selectedDeviceId;
  String? _error;
  bool _loading = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _pollTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _refresh(silent: true),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    if (!mounted || _loading && !silent) return;
    if (ref.read(spotifyConnectionProvider).value == null) return;
    if (!silent) setState(() => _loading = true);
    try {
      final service = ref.read(spotifyRemotePlaybackServiceProvider);
      final values = await Future.wait<Object?>([
        service.currentPlayback(),
        service.devices(),
      ]);
      if (!mounted) return;
      final devices = values[1] as List<SpotifyPlaybackDevice>;
      final snapshot = values[0] as SpotifyPlaybackSnapshot?;
      String? activeDevice;
      for (final device in devices) {
        if (device.isActive) activeDevice = device.id;
      }
      setState(() {
        _devices = devices;
        _snapshot = snapshot;
        _selectedDeviceId =
            activeDevice ??
            (devices.any((device) => device.id == _selectedDeviceId)
                ? _selectedDeviceId
                : null);
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  Future<void> _perform(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      await _refresh(silent: true);
      if (mounted) setState(() => _error = null);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(spotifyConnectionProvider);
    final tokens = connection.when(
      data: (value) => value,
      error: (_, _) => null,
      loading: () => null,
    );
    if (tokens == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final snapshot = _snapshot;
    final selectedDevice =
        _devices.any((device) => device.id == _selectedDeviceId)
        ? _selectedDeviceId
        : null;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer.withValues(alpha: .58),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onSurface.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.devices_rounded, color: colors.primary, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Spotify Connect',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_devices.isNotEmpty)
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDevice,
                    hint: const Text('Choose device'),
                    isDense: true,
                    items: [
                      for (final device in _devices)
                        DropdownMenuItem(
                          value: device.id,
                          child: Text(
                            device.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _busy
                        ? null
                        : (deviceId) {
                            if (deviceId == null) return;
                            setState(() => _selectedDeviceId = deviceId);
                            _perform(
                              () => ref
                                  .read(spotifyRemotePlaybackServiceProvider)
                                  .transferPlayback(deviceId),
                            );
                          },
                  ),
                ),
              IconButton(
                tooltip: 'Refresh Spotify',
                visualDensity: VisualDensity.compact,
                onPressed: _loading ? null : _refresh,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 19),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
            if (_error!.contains('Reconnect Spotify'))
              TextButton.icon(
                onPressed: _busy
                    ? null
                    : () => ref
                          .read(spotifyConnectionProvider.notifier)
                          .connect(),
                icon: const Icon(Icons.login_rounded, size: 17),
                label: const Text('Reconnect and approve'),
              ),
          ],
          if (_devices.isEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Open Spotify on a device, then refresh to control it here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            TextButton.icon(
              onPressed: () => launchUrl(
                Uri.https('open.spotify.com', '/'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Open Spotify'),
            ),
          ] else if (snapshot != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: snapshot.artworkUrl == null
                      ? Container(
                          width: 44,
                          height: 44,
                          color: colors.surfaceContainerHighest,
                          child: const Icon(Icons.music_note_rounded),
                        )
                      : Image.network(
                          snapshot.artworkUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 44,
                            height: 44,
                            color: colors.surfaceContainerHighest,
                            child: const Icon(Icons.music_note_rounded),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${snapshot.artist} · ${snapshot.deviceName ?? 'Spotify'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Previous track',
                  onPressed: _busy
                      ? null
                      : () => _perform(
                          () => ref
                              .read(spotifyRemotePlaybackServiceProvider)
                              .previous(deviceId: selectedDevice),
                        ),
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                IconButton.filled(
                  tooltip: snapshot.isPlaying
                      ? 'Pause Spotify'
                      : 'Resume Spotify',
                  onPressed: _busy
                      ? null
                      : () => _perform(
                          () => snapshot.isPlaying
                              ? ref
                                    .read(spotifyRemotePlaybackServiceProvider)
                                    .pause(deviceId: selectedDevice)
                              : ref
                                    .read(spotifyRemotePlaybackServiceProvider)
                                    .resume(deviceId: selectedDevice),
                        ),
                  icon: Icon(
                    snapshot.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                ),
                IconButton(
                  tooltip: 'Next track',
                  onPressed: _busy
                      ? null
                      : () => _perform(
                          () => ref
                              .read(spotifyRemotePlaybackServiceProvider)
                              .next(deviceId: selectedDevice),
                        ),
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              'Spotify is ready. Start a result or choose a Spotify device.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
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
