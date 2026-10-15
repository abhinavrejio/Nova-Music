import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/personalization/home_personalization_provider.dart';

class HomePersonalizationPage extends ConsumerWidget {
  const HomePersonalizationPage({super.key});

  static const _icons = {
    'quickCollections': Icons.grid_view_rounded,
    'continueListening': Icons.play_circle_fill_rounded,
    'recentlyPlayed': Icons.history_rounded,
    'albums': Icons.album_rounded,
    'artists': Icons.person_rounded,
    'playlists': Icons.queue_music_rounded,
    'genres': Icons.category_rounded,
    'favorites': Icons.favorite_rounded,
    'downloads': Icons.download_done_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(homePersonalizationProvider);
    final notifier = ref.read(homePersonalizationProvider.notifier);
    final theme = Theme.of(context);
    final visibleCount = sections.where((section) => section.visible).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: .10),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 18, 22, 14),
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: 'Back to Settings',
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Make it yours',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Arrange the sections you want to see on Home.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: notifier.restoreDefaults,
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: const Text('Reset'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: .22),
                              theme.colorScheme.tertiary.withValues(alpha: .10),
                              theme.colorScheme.surface.withValues(alpha: .22),
                            ],
                          ),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: .16,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.dashboard_customize_rounded,
                              size: 30,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Home layout',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    '$visibleCount of ${sections.length} sections visible · drag to change their order',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$visibleCount/${sections.length}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                        itemCount: sections.length,
                        onReorderItem: notifier.reorder,
                        itemBuilder: (context, index) {
                          final section = sections[index];
                          final color = section.visible
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant;
                          return Padding(
                            key: ValueKey(section.type),
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: theme.colorScheme.surface.withValues(
                                alpha: .68,
                              ),
                              borderRadius: BorderRadius.circular(19),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(19),
                                onTap: () => notifier.toggle(section.type),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(19),
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: .07),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Icon(
                                          Icons.drag_indicator_rounded,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: .13),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          _icons[section.type.name] ??
                                              Icons.widgets_rounded,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              section.title,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            Text(
                                              section.visible
                                                  ? 'Shown on your Home page'
                                                  : 'Hidden from your Home page',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch.adaptive(
                                        value: section.visible,
                                        onChanged: (_) =>
                                            notifier.toggle(section.type),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
