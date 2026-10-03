import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/player/widgets/mini_player.dart';
import '../providers/audio/audio_player_provider.dart';
import '../providers/playback/playback_controller_provider.dart';
import '../providers/settings_provider.dart';

class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool desktop = constraints.maxWidth >= 900;
        final settings = ref.watch(settingsProvider);
        final theme = Theme.of(context);

        final content = Column(
          children: [
            Expanded(
              child: widget.child,
            ),
            const MiniPlayer(),
          ],
        );

        return CallbackShortcuts(
          bindings: {
            const SingleActivator(
              LogicalKeyboardKey.space,
            ): () {
              ref.read(audioPlayerProvider).togglePlayPause();
            },

            const SingleActivator(
              LogicalKeyboardKey.arrowRight,
            ): () {
              ref.read(playbackControllerProvider).next();
            },

            const SingleActivator(
              LogicalKeyboardKey.arrowLeft,
            ): () {
              ref.read(playbackControllerProvider).previous();
            },

            const SingleActivator(
              LogicalKeyboardKey.keyL,
              control: true,
            ): () {
              context.go('/library');

              setState(() {
                currentIndex = 2;
              });
            },
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  gradient: settings.gradientBackground
                      ? LinearGradient(
                          colors: [
                            theme.scaffoldBackgroundColor,
                            theme.colorScheme.secondary
                                .withValues(alpha: 0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: desktop
                    ? Row(
                        children: [
                          _NovaRail(
                            currentIndex: currentIndex,
                            onSelected: _goTo,
                            compact: settings.compactSidebar,
                            showTagline: settings.sidebarShowTagline,
                          ),
                          Expanded(
                            child: content,
                          ),
                        ],
                      )
                    : content,
              ),
              bottomNavigationBar: desktop
                  ? null
                  : NavigationBar(
                      selectedIndex: currentIndex,
                      destinations: _destinations,
                      onDestinationSelected: _goTo,
                    ),
            ),
          ),
        );
      },
    );
  }

  void _goTo(int index) {
    const paths = [
      '/',
      '/search',
      '/library',
      '/settings',
    ];

    if (index < 0 || index >= paths.length) {
      return;
    }

    context.go(paths[index]);

    setState(() {
      currentIndex = index;
    });
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

class _NovaRail extends StatelessWidget {
  const _NovaRail({
    required this.currentIndex,
    required this.onSelected,
    required this.compact,
    required this.showTagline,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final bool compact;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: compact ? 82 : 232,
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 18,
        24,
        compact ? 8 : 14,
        18,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.78),
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.45),
          ),
        ),
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
            child: NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onSelected,
              labelType: compact
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              useIndicator: true,
              minWidth: compact ? 56 : 72,
              groupAlignment: -0.85,
              destinations: List.generate(
                _destinations.length,
                (index) {
                  final destination = _destinations[index];
                  final selected = currentIndex == index;

                  return NavigationRailDestination(
                    icon: AnimatedScale(
                      scale: selected ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: destination.icon,
                    ),
                    selectedIcon: AnimatedScale(
                      scale: 1.08,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: destination.selectedIcon,
                    ),
                    label: Text(destination.label),
                  );
                },
              ),
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
    );
  }
}