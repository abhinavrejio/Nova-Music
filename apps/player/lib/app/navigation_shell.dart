import 'dart:math' as math;
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/app_settings.dart';
import '../providers/playlists/playlist_provider.dart';
import '../providers/playback/current_song_provider.dart';
import '../providers/settings_provider.dart';
import '../features/player/widgets/mini_player.dart';
import '../features/library/pages/playlist_detail_page.dart';

class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
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
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(path);
    final desktop = MediaQuery.sizeOf(context).width >= 900;
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
            Row(
              children: [
                _NovaRail(
                  currentIndex: selectedIndex,
                  onSelected: _goTo,
                  compact: settings.compactSidebar,
                  showTagline: settings.sidebarShowTagline,
                  animationsEnabled: motion,
                  glassQuality: settings.glassQuality,
                  liquidGlass: settings.liquidGlass,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: content),
                      const Positioned.fill(child: MiniPlayer()),
                    ],
                  ),
                ),
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
    required this.compact,
    required this.showTagline,
    required this.animationsEnabled,
    required this.glassQuality,
    required this.liquidGlass,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final bool compact;
  final bool showTagline;
  final bool animationsEnabled;
  final GlassQuality glassQuality;
  final bool liquidGlass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pinnedPlaylists = ref
        .watch(playlistProvider)
        .where((playlist) => playlist.isPinned)
        .toList();

    final width = compact ? 82.0 : 232.0;
    final blur = switch (glassQuality) {
      GlassQuality.low => 8.0,
      GlassQuality.balanced => 18.0,
      GlassQuality.high => 28.0,
    };

    return SizedBox(
      width: width + 24,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 0, 96),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
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
                borderRadius: BorderRadius.circular(28),
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
                  if (!compact)
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
                                Icons.bolt_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'NOVA',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: NavigationRail(
                            selectedIndex: currentIndex,
                            onDestinationSelected: onSelected,
                            backgroundColor: Colors.transparent,
                            labelType: compact
                                ? NavigationRailLabelType.none
                                : NavigationRailLabelType.all,
                            useIndicator: true,
                            minWidth: compact ? 56 : 72,
                            groupAlignment: -0.85,
                            destinations: List.generate(_destinations.length, (
                              index,
                            ) {
                              final destination = _destinations[index];
                              final selected = currentIndex == index;

                              return NavigationRailDestination(
                                icon: _scaleIcon(
                                  destination.icon,
                                  selected: selected,
                                ),
                                selectedIcon: _scaleIcon(
                                  destination.selectedIcon ?? destination.icon,
                                  selected: true,
                                ),
                                label: Text(destination.label),
                              );
                            }),
                          ),
                        ),
                        if (pinnedPlaylists.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'PINNED PLAYLISTS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  letterSpacing: 1.1,
                                ),
                              ),
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
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showTagline && !compact)
                    Text(
                      'YOUR SPACE,\nYOUR SOUND.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.4,
                        height: 1.4,
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

  Widget _scaleIcon(Widget icon, {required bool selected}) {
    if (!animationsEnabled) {
      return icon;
    }

    return AnimatedScale(
      scale: selected ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: icon,
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
    if (widget.enabled && widget.motionEnabled) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _AnimatedGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && widget.motionEnabled) {
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
