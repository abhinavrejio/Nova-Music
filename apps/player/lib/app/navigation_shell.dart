import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/colors.dart';
import '../features/player/widgets/mini_player.dart';
import '../providers/audio/audio_player_provider.dart';
import '../providers/playback/playback_controller_provider.dart';

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
        final desktop = constraints.maxWidth >= 900;
        final content = Column(
          children: [
            Expanded(child: widget.child),
            const MiniPlayer(),
          ],
        );

        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.space): () {
              ref.read(audioPlayerProvider).togglePlayPause();
            },
            const SingleActivator(LogicalKeyboardKey.arrowRight): () {
              ref.read(playbackControllerProvider).next();
            },
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
              ref.read(playbackControllerProvider).previous();
            },
            const SingleActivator(LogicalKeyboardKey.keyL, control: true): () {
              context.go('/library');
              setState(() => currentIndex = 2);
            },
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: desktop
                    ? Row(
                        children: [
                          _NovaRail(
                            currentIndex: currentIndex,
                            onSelected: _goTo,
                          ),
                          Expanded(child: content),
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
    final paths = ['/', '/search', '/library', '/settings'];
    context.go(paths[index]);
    setState(() => currentIndex = index);
  }
}

const _destinations = [
  NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
  NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Search'),
  NavigationDestination(icon: Icon(Icons.library_music_rounded), label: 'Library'),
  NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'Settings'),
];

class _NovaRail extends StatelessWidget {
  const _NovaRail({required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.fromLTRB(18, 28, 14, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(Icons.bolt_rounded, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'NOVA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 42),
          Expanded(
            child: NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onSelected,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -1,
              destinations: _destinations
                  .map(
                    (destination) => NavigationRailDestination(
                      icon: destination.icon,
                      selectedIcon: destination.selectedIcon,
                      label: Text(destination.label),
                    ),
                  )
                  .toList(),
            ),
          ),
          Text(
            'YOUR SPACE,\nYOUR SOUND.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.4,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}