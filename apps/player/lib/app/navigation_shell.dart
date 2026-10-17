import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/app_settings.dart';
import '../providers/playlists/playlist_provider.dart';
import '../providers/library/liked_songs_provider.dart';
import '../providers/playback/current_song_provider.dart';
import '../providers/playback/playback_controller_provider.dart';
import '../providers/playback/playback_provider.dart';
import '../providers/audio/audio_player_provider.dart';
import '../providers/settings_provider.dart';
import '../features/player/widgets/mini_player.dart';
import '../features/library/pages/playlist_detail_page.dart';
import '../providers/playback/queue_provider.dart';
import '../features/lyrics/widgets/lyrics_now_playing_panel.dart';
import '../services/keyboard_shortcut_service.dart';
import '../features/settings/widgets/shortcut_capture_dialog.dart';

class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handlePlaybackShortcut);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handlePlaybackShortcut);
    super.dispose();
  }

  int _selectedIndex(String path) {
    if (path == '/settings' || path.startsWith('/settings/')) return 3;
    if (path == '/library' || path.startsWith('/library/')) return 2;
    if (path == '/search' || path.startsWith('/search/')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final currentSong = ref.watch(currentSongProvider);
    final theme = Theme.of(context);
    String path = '/';
    try {
      path = GoRouterState.of(context).uri.path;
    } catch (_) {
      path = ModalRoute.of(context)?.settings.name ?? '/';
    }
    final selectedIndex = _selectedIndex(path);
    final desktop = MediaQuery.sizeOf(context).width >= 800;
    final wideDesktop = MediaQuery.sizeOf(context).width >= 1180;
    final motion = settings.animationsEnabled;

    final content = ClipRect(
      child: AnimatedSwitcher(
        duration: motion ? const Duration(milliseconds: 360) : Duration.zero,
        reverseDuration: motion
            ? const Duration(milliseconds: 240)
            : Duration.zero,
        switchInCurve: Curves.easeOutCubic,
        child: KeyedSubtree(key: ValueKey(path), child: widget.child),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: _AnimatedGradientBackground(
              base: settings.amoledBlack
                  ? Colors.black
                  : theme.scaffoldBackgroundColor,
              accent: Color(settings.backgroundColorValue),
              enabled:
                  settings.gradientBackground &&
                  settings.backgroundStyle == BackgroundStyle.gradient &&
                  !settings.amoledBlack,
              style: settings.amoledBlack
                  ? BackgroundStyle.solidColor
                  : settings.backgroundStyle,
              artwork: currentSong?.artwork,
              wallpaperPath: settings.wallpaperPath,
              amoledBlack: settings.amoledBlack,
              motionEnabled: motion,
            ),
          ),
          if (desktop)
            Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _NovaRail(
                        currentIndex: selectedIndex,
                        onSelected: _goTo,
                        sidebarWidth: settings.leftSidebarWidth,
                        compact:
                            MediaQuery.sizeOf(context).width < 1050 &&
                            settings.compactSidebar,
                        animationsEnabled: motion,
                        glassQuality: settings.glassQuality,
                        liquidGlass: settings.liquidGlass,
                      ),
                      _ResizeHandle(
                        label: 'Resize navigation sidebar',
                        onDelta: (delta) => ref
                            .read(settingsProvider.notifier)
                            .setLeftSidebarWidth(
                              settings.leftSidebarWidth + delta,
                            ),
                      ),
                      Expanded(child: ClipRect(child: content)),
                      if (wideDesktop) ...[
                        _ResizeHandle(
                          label: 'Resize Now Playing sidebar',
                          onDelta: (delta) => ref
                              .read(settingsProvider.notifier)
                              .setRightSidebarWidth(
                                settings.rightSidebarWidth - delta,
                              ),
                        ),
                        _NowPlayingPanel(width: settings.rightSidebarWidth),
                      ],
                    ],
                  ),
                ),
                const MiniPlayer(),
              ],
            )
          else
            Stack(
              children: [
                Positioned.fill(child: content),
                const Positioned.fill(child: MiniPlayer()),
              ],
            ),
        ],
      ),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              destinations: _destinations,
              onDestinationSelected: _goTo,
            ),
    );
  }

  bool _handlePlaybackShortcut(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext?.findAncestorWidgetOfExactType<EditableText>() != null ||
        focusedContext?.findAncestorWidgetOfExactType<TextField>() != null ||
        focusedContext
                ?.findAncestorWidgetOfExactType<ShortcutCaptureDialog>() !=
            null) {
      return false;
    }

    final song = ref.read(currentSongProvider);
    if (song == null) return false;
    final audio = ref.read(audioPlayerProvider);

    final shortcuts = ref.read(settingsProvider);
    if (KeyboardShortcutService.matches(shortcuts.playPauseShortcut, event)) {
      unawaited(audio.togglePlayPauseFor(song.path));
      return true;
    }
    if (KeyboardShortcutService.matches(shortcuts.nextTrackShortcut, event)) {
      unawaited(ref.read(playbackControllerProvider).next());
      return true;
    }
    if (KeyboardShortcutService.matches(
      shortcuts.previousTrackShortcut,
      event,
    )) {
      unawaited(ref.read(playbackControllerProvider).previous());
      return true;
    }

    final position = ref.read(positionProvider).value ?? audio.position;
    final duration = ref.read(durationProvider).value ?? song.duration;
    if (KeyboardShortcutService.matches(shortcuts.seekForwardShortcut, event)) {
      final target = position + const Duration(seconds: 5);
      unawaited(audio.seek(target > duration ? duration : target));
      return true;
    }
    if (KeyboardShortcutService.matches(
      shortcuts.seekBackwardShortcut,
      event,
    )) {
      final target = position - const Duration(seconds: 5);
      unawaited(audio.seek(target.isNegative ? Duration.zero : target));
      return true;
    }
    return false;
  }

  void _goTo(int index) {
    const paths = ['/', '/search', '/library', '/settings'];

    if (index >= 0 && index < paths.length) {
      context.go(paths[index]);
    }
  }
}

const List<NavigationDestination> _destinations = [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.search_outlined),
    selectedIcon: Icon(Icons.search_rounded),
    label: 'Search',
  ),
  NavigationDestination(
    icon: Icon(Icons.library_music_outlined),
    selectedIcon: Icon(Icons.library_music_rounded),
    label: 'Library',
  ),
  NavigationDestination(
    icon: Icon(Icons.tune_outlined),
    selectedIcon: Icon(Icons.tune_rounded),
    label: 'Settings',
  ),
];

class _NovaRail extends ConsumerWidget {
  const _NovaRail({
    required this.currentIndex,
    required this.onSelected,
    required this.sidebarWidth,
    required this.compact,
    required this.animationsEnabled,
    required this.glassQuality,
    required this.liquidGlass,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final double sidebarWidth;
  final bool compact;
  final bool animationsEnabled;
  final GlassQuality glassQuality;
  final bool liquidGlass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pinnedPlaylists = ref.watch(playlistProvider);
    final likedCount = ref.watch(likedSongsProvider).length;

    final width = sidebarWidth;
    final blur = switch (glassQuality) {
      GlassQuality.low => 8.0,
      GlassQuality.balanced => 18.0,
      GlassQuality.high => 28.0,
    };

    return SizedBox(
      width: width + 24,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 0, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: liquidGlass ? blur : 0,
              sigmaY: liquidGlass ? blur : 0,
            ),
            child: AnimatedContainer(
              duration: animationsEnabled
                  ? const Duration(milliseconds: 260)
                  : Duration.zero,
              curve: Curves.easeOutCubic,
              width: width,
              padding: EdgeInsets.fromLTRB(
                compact ? 10 : 18,
                24,
                compact ? 8 : 14,
                18,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(
                  alpha: liquidGlass
                      ? switch (glassQuality) {
                          GlassQuality.low => .78,
                          GlassQuality.balanced => .64,
                          GlassQuality.high => .52,
                        }
                      : .92,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: .12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: .16),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(
                            width: 34,
                            height: 34,
                            child: Icon(
                              Icons.equalizer_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'NOCTURNE',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              for (
                                var index = 0;
                                index < _destinations.length - 1;
                                index++
                              )
                                Builder(
                                  builder: (context) {
                                    final destination = _destinations[index];
                                    final selected = currentIndex == index;
                                    final icon = selected
                                        ? destination.selectedIcon
                                        : destination.icon;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Material(
                                        color: selected
                                            ? theme
                                                  .colorScheme
                                                  .surfaceContainerHighest
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        child: ListTile(
                                          dense: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            side: BorderSide(
                                              color: selected
                                                  ? theme.colorScheme.primary
                                                  : Colors.transparent,
                                              width: selected ? 2 : 0,
                                            ),
                                          ),
                                          leading: icon,
                                          title: Text(destination.label),
                                          selected: selected,
                                          onTap: () => onSelected(index),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                        ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 8, 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'YOUR COLLECTION',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Create playlist',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => context.go('/library'),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: const Icon(Icons.favorite_rounded),
                              title: const Text(
                                'Liked songs',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('$likedCount songs'),
                              onTap: () => context.go('/library'),
                            ),
                          ),
                          SizedBox(
                            height: (pinnedPlaylists.length.clamp(1, 3) * 42)
                                .toDouble(),
                            child: ListView.builder(
                              itemCount: pinnedPlaylists.length,
                              itemBuilder: (context, index) {
                                final playlist = pinnedPlaylists[index];
                                return Tooltip(
                                  message: playlist.name,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: compact ? 18 : 12,
                                      ),
                                      leading: Icon(
                                        Icons.queue_music_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                                      title: compact
                                          ? null
                                          : Text(
                                              playlist.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => PlaylistDetailPage(
                                            playlist: playlist,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!compact) ...[
                    const Divider(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showProfileMenu(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 17,
                                    backgroundColor: Color(0xFF47362B),
                                    child: Icon(Icons.person_rounded, size: 18),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Local listener',
                                          style: theme.textTheme.labelMedium,
                                        ),
                                        Text(
                                          'Music library',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'More options',
                          onSelected: (value) => context.go(value),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: '/settings',
                              child: Text('Settings'),
                            ),
                            PopupMenuItem(
                              value: '/search',
                              child: Text('Connect music services'),
                            ),
                          ],
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.more_horiz_rounded, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 370,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: .12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .35),
                blurRadius: 42,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      ),
                    ),
                    child: const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.person_rounded, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your listening space',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Local listener · Music library',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface
                      .withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.headphones_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Your library is ready. Add music folders or connect a supported catalog in Search.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.go('/search');
                      },
                      icon: const Icon(Icons.link_rounded),
                      label: const Text('Music services'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.go('/settings');
                      },
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Settings'),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({required this.label, required this.onDelta});

  final String label;
  final ValueChanged<double> onDelta;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) => onDelta(details.delta.dx),
        child: SizedBox(
          width: 12,
          child: Center(
            child: Container(
              width: 2,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: .17),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _NowPlayingPanel extends ConsumerStatefulWidget {
  const _NowPlayingPanel({required this.width});

  final double width;

  @override
  ConsumerState<_NowPlayingPanel> createState() => _NowPlayingPanelState();
}

class _NowPlayingPanelState extends ConsumerState<_NowPlayingPanel> {
  bool _showLyrics = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final song = ref.watch(currentSongProvider);
    final queue = ref.watch(queueProvider);

    return SizedBox(
      width: widget.width,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 14, 14, 12),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: .82),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: .08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'NOW PLAYING',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Open queue',
                  onPressed: () => context.push('/queue'),
                  icon: const Icon(Icons.queue_music_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: song?.artwork == null
                    ? ColoredBox(
                        color: theme.colorScheme.surfaceContainerHigh,
                        child: Icon(
                          Icons.album_rounded,
                          size: 62,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Image.memory(song!.artwork!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              song?.title ?? 'Choose something to play',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              song?.artist.isNotEmpty == true
                  ? song!.artist
                  : 'Your library is ready',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _PanelTab(
                  title: 'Lyrics',
                  selected: _showLyrics,
                  onTap: () => setState(() => _showLyrics = true),
                ),
                const SizedBox(width: 8),
                _PanelTab(
                  title: 'Up next',
                  selected: !_showLyrics,
                  onTap: () => setState(() => _showLyrics = false),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: song == null
                  ? Center(
                      child: Text(
                        'Your next favorite starts in Search.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : _showLyrics
                  ? LyricsNowPlayingPanel(
                      title: song.title,
                      artist: song.artist,
                      album: song.album,
                      trackId: song.path,
                      duration: song.duration,
                    )
                  : queue.isEmpty
                  ? Center(
                      child: Text(
                        'Nothing else in the queue',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: queue.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final queued = queue[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox.square(
                              dimension: 34,
                              child: queued.artwork == null
                                  ? ColoredBox(
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHigh,
                                      child: const Icon(
                                        Icons.music_note_rounded,
                                        size: 18,
                                      ),
                                    )
                                  : Image.memory(
                                      queued.artwork!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          title: Text(
                            queued.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            queued.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelTab extends StatelessWidget {
  const _PanelTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 36),
      ),
      child: Text(title),
    );
  }
}

class _AnimatedGradientBackground extends StatefulWidget {
  const _AnimatedGradientBackground({
    required this.base,
    required this.accent,
    required this.enabled,
    required this.style,
    required this.artwork,
    required this.wallpaperPath,
    required this.amoledBlack,
    required this.motionEnabled,
  });

  final Color base;
  final Color accent;
  final bool enabled;
  final BackgroundStyle style;
  final Uint8List? artwork;
  final String? wallpaperPath;
  final bool amoledBlack;
  final bool motionEnabled;

  @override
  State<_AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    if (widget.enabled &&
        widget.motionEnabled &&
        !Platform.environment.containsKey('FLUTTER_TEST')) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldAnimate =
        widget.enabled &&
        widget.motionEnabled &&
        !Platform.environment.containsKey('FLUTTER_TEST');
    if (shouldAnimate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final angle = _controller.value * math.pi * 2;
      if (widget.amoledBlack) {
        return const ColoredBox(color: Colors.black);
      }
      final backgroundImage = widget.style == BackgroundStyle.albumArtwork
          ? widget.artwork
          : null;
      final wallpaper =
          widget.style == BackgroundStyle.wallpaper &&
              !kIsWeb &&
              widget.wallpaperPath != null
          ? File(widget.wallpaperPath!)
          : null;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundImage != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 44, sigmaY: 44),
              child: Opacity(
                opacity: .56,
                child: Image.memory(backgroundImage, fit: BoxFit.cover),
              ),
            )
          else if (wallpaper != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Image.file(
                wallpaper,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    ColoredBox(color: widget.base),
              ),
            )
          else if (widget.style == BackgroundStyle.solidColor)
            ColoredBox(color: widget.accent)
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: widget.base,
                gradient: widget.enabled
                    ? RadialGradient(
                        center: Alignment(
                          math.cos(angle) * .72,
                          math.sin(angle) * .72,
                        ),
                        radius: 1.65,
                        colors: [
                          widget.accent.withValues(alpha: .30),
                          widget.base,
                          widget.accent.withValues(alpha: .05),
                        ],
                        stops: const [0, .58, 1],
                      )
                    : null,
              ),
            ),
        ],
      );
    },
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
