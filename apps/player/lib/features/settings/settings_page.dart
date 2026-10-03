import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  ConsumerState<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends ConsumerState<SettingsPage> {
  String _selected = 'General';

  final List<_SettingsCategory> _categories = const [
    _SettingsCategory(
      title: 'General',
      subtitle: 'Startup and interface',
      icon: Icons.settings_rounded,
    ),
    _SettingsCategory(
      title: 'Playback & Audio',
      subtitle: 'Playback and sound',
      icon: Icons.play_circle_outline_rounded,
    ),
    _SettingsCategory(
      title: 'Appearance',
      subtitle: 'Theme and interface',
      icon: Icons.palette_outlined,
    ),
    _SettingsCategory(
      title: 'Search',
      subtitle: 'Search preferences',
      icon: Icons.search_rounded,
    ),
    _SettingsCategory(
      title: 'Personalization',
      subtitle: 'Home experience',
      icon: Icons.tune_rounded,
    ),
    _SettingsCategory(
      title: 'Downloads',
      subtitle: 'Offline music',
      icon: Icons.download_rounded,
    ),
    _SettingsCategory(
      title: 'Advanced',
      subtitle: 'System behavior',
      icon: Icons.build_outlined,
    ),
    _SettingsCategory(
      title: 'About',
      subtitle: 'Nova Music',
      icon: Icons.info_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings =
        ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final desktop =
              constraints.maxWidth >= 950;

          if (!desktop) {
            return _buildMobile(
              context,
              settings,
            );
          }

          return Row(
            children: [
              _buildSidebar(
                context,
              ),
              Expanded(
                child: _buildContent(
                  context,
                  settings,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primary,
                      borderRadius:
                          BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOVA',
                        style: theme
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight:
                              FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Settings',
                        style: theme
                            .textTheme
                            .labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                children: [
                  const _SidebarLabel(
                    'SETTINGS',
                  ),
                  const SizedBox(height: 8),

                  for (final category
                      in _categories)
                    _SidebarItem(
                      category: category,
                      selected:
                          _selected ==
                              category.title,
                      onTap: () {
                        setState(() {
                          _selected =
                              category.title;
                        });
                      },
                    ),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  'Nova Music',
                  style: theme
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppSettings settings,
  ) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 920,
          ),
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              42,
              34,
              42,
              48,
            ),
            child: AnimatedSwitcher(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              child: _buildSelectedPage(
                context,
                settings,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPage(
    BuildContext context,
    AppSettings settings,
  ) {
    switch (_selected) {
      case 'General':
        return _general(
          context,
          settings,
        );

      case 'Playback & Audio':
        return _playbackAudio(
          context,
          settings,
        );

      case 'Appearance':
        return _appearance(
          context,
          settings,
        );

      case 'Search':
        return _search(
          context,
          settings,
        );

      case 'Personalization':
        return _personalization(
          context,
          settings,
        );

      case 'Downloads':
        return _downloads(
          context,
        );

      case 'Advanced':
        return _advanced(
          context,
          settings,
        );

      case 'About':
        return _about(
          context,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMobile(
    BuildContext context,
    AppSettings settings,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(
            _selected,
          ),
          actions: [
            PopupMenuButton<String>(
              initialValue: _selected,
              onSelected: (value) {
                setState(() {
                  _selected = value;
                });
              },
              itemBuilder: (context) {
                return _categories
                    .map(
                      (category) =>
                          PopupMenuItem(
                        value:
                            category.title,
                        child: Text(
                          category.title,
                        ),
                      ),
                    )
                    .toList();
              },
            ),
          ],
        ),
        SliverPadding(
          padding:
              const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: _buildSelectedPage(
              context,
              settings,
            ),
          ),
        ),
      ],
    );
  }

  Widget _general(
    BuildContext context,
    AppSettings settings,
  ) {
    return _page(
      context,
      icon: Icons.settings_rounded,
      title: 'General',
      subtitle:
          'Configure how Nova Music behaves.',
      children: [
        _sectionTitle(
          'STARTUP',
          'Control what Nova does when you start using it.',
        ),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon:
                  Icons.play_arrow_rounded,
              title: 'Autoplay',
              subtitle:
                  'Continue playback automatically.',
              value:
                  settings.autoPlay,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setAutoPlay,
            ),
          ],
        ),

        _sectionTitle(
          'INTERFACE',
          'Control the overall application interface.',
        ),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon:
                  Icons.speed_rounded,
              title:
                  'Hardware Acceleration',
              subtitle:
                  'Use hardware acceleration where available.',
              value:
                  settings.hardwareAcceleration,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setHardwareAcceleration,
            ),
          ],
        ),
      ],
    );
  }

  Widget _playbackAudio(
    BuildContext context,
    AppSettings settings,
  ) {
    return _page(
      context,
      icon:
          Icons.play_circle_outline_rounded,
      title: 'Playback & Audio',
      subtitle:
          'Control playback, controls, and sound.',
      children: [
        _sectionTitle(
          'PLAYBACK',
          'Control how songs are played and what happens next.',
        ),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon:
                  Icons.play_arrow_rounded,
              title: 'Autoplay',
              subtitle:
                  'Continue with another song when the queue ends.',
              value:
                  settings.autoPlay,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setAutoPlay,
            ),
            _switchTile(
              context,
              icon:
                  Icons.shuffle_rounded,
              title: 'Shuffle',
              subtitle:
                  'Play queued songs in a random order.',
              value:
                  settings.shuffle,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setShuffle,
            ),
            _navigationTile(
              context,
              icon:
                  Icons.repeat_rounded,
              title: 'Repeat',
              subtitle:
                  _repeatLabel(
                settings.repeatMode,
              ),
              onTap: () =>
                  _showRepeatDialog(
                context,
                settings,
              ),
            ),
          ],
        ),

        _sectionTitle(
          'CONTROLS',
          'Choose which playback controls are available in the mini player.',
        ),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon:
                  Icons.shuffle_rounded,
              title: 'Show Shuffle',
              subtitle:
                  'Show the shuffle control in the mini player.',
              value:
                  settings.miniPlayerShowShuffle,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setMiniPlayerShowShuffle,
            ),
            _switchTile(
              context,
              icon:
                  Icons.repeat_rounded,
              title: 'Show Repeat',
              subtitle:
                  'Show the repeat control in the mini player.',
              value:
                  settings.miniPlayerShowRepeat,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setMiniPlayerShowRepeat,
            ),
            _switchTile(
              context,
              icon:
                  Icons.queue_music_rounded,
              title: 'Show Queue',
              subtitle:
                  'Show the queue button in the mini player.',
              value:
                  settings.miniPlayerShowQueue,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setMiniPlayerShowQueue,
            ),
          ],
        ),

        _sectionTitle(
          'AUDIO',
          'Control audio quality.',
        ),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon:
                  Icons.high_quality_rounded,
              title:
                  'High Quality Audio',
              subtitle:
                  'Prefer the highest quality available for local files.',
              value:
                  settings.highQualityAudio,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setHighQualityAudio,
            ),
          ],
        ),
      ],
    );
  }

  Widget _appearance(
    BuildContext context,
    AppSettings settings,
  ) {
    final colors = [
      0xFFFF6B5F,
      0xFF4D9FFF,
      0xFF55D6BE,
      0xFFA879FF,
      0xFFFF5F9E,
      0xFFFFB347,
      0xFF5FD7FF,
      0xFF8DDC65,
    ];

    return _page(
      context,
      icon: Icons.palette_outlined,
      title: 'Appearance',
      subtitle:
          'Customize Nova Music appearance and navigation.',
      children: [
        _sectionTitle(
          'APPEARANCE',
          'Customize the visual style of Nova Music.',
        ),
        _settingsCard(
          context,
          children: [
            _themeTile(
              context,
              settings,
            ),

            _switchTile(
              context,
              icon:
                  Icons.dark_mode_rounded,
              title: 'AMOLED Black',
              subtitle:
                  'Use true black backgrounds in dark mode.',
              value:
                  settings.amoledBlack,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setAmoledBlack,
            ),

            _switchTile(
              context,
              icon:
                  Icons.gradient_rounded,
              title: 'Background Gradient',
              subtitle:
                  'Show Nova background gradients.',
              value:
                  settings.backgroundGradient,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setBackgroundGradient,
            ),

            _switchTile(
              context,
              icon:
                  Icons.blur_on_rounded,
              title: 'Liquid Glass',
              subtitle:
                  'Use translucent glass surfaces throughout Nova.',
              value:
                  settings.liquidGlass,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setLiquidGlass,
            ),

            _accentColorTile(
              context,
              colors,
              settings,
            ),
          ],
        ),

        _sectionTitle(
          'UI SCALE',
          'Resize the entire Nova interface.',
        ),
        _settingsCard(
          context,
          children: [
            _scaleTile(
              context,
              settings,
            ),
          ],
        ),

        _sectionTitle(
          'SIDEBAR',
          'Customize desktop navigation.',
        ),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon:
                  Icons.view_sidebar_rounded,
              title: 'Compact Sidebar',
              subtitle:
                  'Use a narrower desktop navigation sidebar.',
              value:
                  settings.compactSidebar,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setCompactSidebar,
            ),
            _switchTile(
              context,
              icon:
                  Icons.short_text_rounded,
              title: 'Show Sidebar Tagline',
              subtitle:
                  'Display the Nova message at the bottom.',
              value:
                  settings.sidebarShowTagline,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setSidebarShowTagline,
            ),
          ],
        ),
      ],
    );
  }

  Widget _search(
    BuildContext context,
    AppSettings settings,
  ) {
    return _page(
      context,
      icon: Icons.search_rounded,
      title: 'Search',
      subtitle:
          'Choose what Nova shows in search results.',
      children: [
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon: Icons.music_note_rounded,
              title: 'Songs',
              subtitle:
                  'Show songs in search results.',
              value:
                  settings.searchShowSongs,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setSearchShowSongs,
            ),
            _switchTile(
              context,
              icon: Icons.queue_music_rounded,
              title: 'Playlists',
              subtitle:
                  'Show playlists in search results.',
              value:
                  settings.searchShowPlaylists,
              onChanged: ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setSearchShowPlaylists,
            ),
          ],
        ),
      ],
    );
  }

  Widget _personalization(
    BuildContext context,
    AppSettings settings,
  ) {
    return _page(
      context,
      icon: Icons.tune_rounded,
      title: 'Personalization',
      subtitle:
          'Customize the Nova home experience.',
      children: [
        _settingsCard(
          context,
          children: const [
            _InfoTile(
              icon:
                  Icons.auto_awesome_rounded,
              title:
                  'Home personalization',
              subtitle:
                  'Your home sections are managed by Nova personalization.',
            ),
            _InfoTile(
              icon:
                  Icons.library_music_rounded,
              title:
                  'More controls coming',
              subtitle:
                  'Home section ordering and visibility can be added here.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _downloads(
    BuildContext context,
  ) {
    return _page(
      context,
      icon:
          Icons.download_rounded,
      title: 'Downloads',
      subtitle:
          'Manage offline music and storage.',
      children: [
        _settingsCard(
          context,
          children: const [
            _InfoTile(
              icon:
                  Icons.folder_rounded,
              title:
                  'Download location',
              subtitle:
                  'Download location management will appear here.',
            ),
            _InfoTile(
              icon:
                  Icons.storage_rounded,
              title:
                  'Storage',
              subtitle:
                  'Storage usage information will appear here.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _advanced(
    BuildContext context,
    AppSettings settings,
  ) {
    return _page(
      context,
      icon: Icons.build_outlined,
      title: 'Advanced',
      subtitle:
          'Advanced Nova Music configuration.',
      children: [
        _settingsCard(
          context,
          children: [
            _InfoTile(
              icon:
                  Icons.memory_rounded,
              title:
                  'Hardware Acceleration',
              subtitle:
                  settings.hardwareAcceleration
                      ? 'Enabled'
                      : 'Disabled',
            ),
            _dangerTile(
              context,
              icon:
                  Icons.restore_rounded,
              title:
                  'Reset All Settings',
              subtitle:
                  'Restore Nova Music settings to their defaults.',
              onTap:
                  () => _confirmReset(
                context,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _about(
    BuildContext context,
  ) {
    return _page(
      context,
      icon: Icons.info_outline_rounded,
      title: 'About',
      subtitle:
          'Information about Nova Music.',
      children: [
        _settingsCard(
          context,
          children: const [
            _InfoTile(
              icon:
                  Icons.bolt_rounded,
              title: 'Nova Music',
              subtitle:
                  'Your personal music experience.',
            ),
            _InfoTile(
              icon:
                  Icons.code_rounded,
              title: 'Application',
              subtitle:
                  'Built with Flutter.',
            ),
          ],
        ),
      ],
    );
  }

  Widget _page(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.14),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color:
                    theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme
                        .textTheme
                        .bodySmall
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

        const SizedBox(height: 34),

        ...children,
      ],
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        2,
        0,
        2,
        10,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 28,
      ),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainer,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              theme.dividerColor,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>
        onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          _tileIcon(
            context,
            icon,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _navigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            _tileIcon(
              context,
              icon,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tileIcon(
    BuildContext context,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .primary
            .withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 19,
        color:
            theme.colorScheme.primary,
      ),
    );
  }

  Widget _themeTile(
    BuildContext context,
    AppSettings settings,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tileIcon(
                context,
                Icons.brightness_6_rounded,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Choose how Nova follows your display theme.',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value:
                    ThemeMode.system,
                icon: Icon(
                  Icons.settings_suggest_rounded,
                ),
                label: Text('System'),
              ),
              ButtonSegment(
                value:
                    ThemeMode.dark,
                icon: Icon(
                  Icons.dark_mode_rounded,
                ),
                label: Text('Dark'),
              ),
              ButtonSegment(
                value:
                    ThemeMode.light,
                icon: Icon(
                  Icons.light_mode_rounded,
                ),
                label: Text('Light'),
              ),
            ],
            selected: {
              settings.themeMode,
            },
            onSelectionChanged:
                (selection) {
              if (selection.isEmpty) {
                return;
              }

              ref
                  .read(
                    settingsProvider
                        .notifier,
                  )
                  .setThemeMode(
                    selection.first,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _accentColorTile(
    BuildContext context,
    List<int> colors,
    AppSettings settings,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding:
          const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tileIcon(
                context,
                Icons.color_lens_rounded,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accent Color',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Used for highlights and selected controls.',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map(
              (value) {
                final selected =
                    value ==
                        settings
                            .accentColorValue;

                return GestureDetector(
                  onTap: () {
                    ref
                        .read(
                          settingsProvider
                              .notifier,
                        )
                        .setAccentColor(
                          value,
                        );
                  },
                  child: AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),
                    width: 36,
                    height: 36,
                    decoration:
                        BoxDecoration(
                      color:
                          Color(value),
                      shape:
                          BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color:
                                  Colors.white,
                              width: 3,
                            )
                          : null,
                      boxShadow:
                          selected
                              ? [
                                  BoxShadow(
                                    color:
                                        Color(value).withValues(alpha: 0.35),
                                    blurRadius:
                                        12,
                                  ),
                                ]
                              : null,
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color:
                                Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Current accent',
            style: theme
                .textTheme
                .labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _scaleTile(
    BuildContext context,
    AppSettings settings,
  ) {
    final notifier =
        ref.read(
          settingsProvider.notifier,
        );

    return Padding(
      padding:
          const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tileIcon(
                context,
                Icons.zoom_in_rounded,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UI Scale',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${(settings.uiScale * 100).round()}% interface scale',
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    notifier.setUiScale(
                  1.0,
                ),
                child:
                    const Text('Reset'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Slider(
            min:
                AppSettings.minUiScale,
            max:
                AppSettings.maxUiScale,
            divisions: 6,
            value:
                settings.uiScale,
            label:
                '${(settings.uiScale * 100).round()}%',
            onChanged:
                notifier.setUiScale,
          ),

          const Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Text('90%'),
              Text('100%'),
              Text('110%'),
              Text('120%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dangerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            _tileIcon(
              context,
              icon,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                      color:
                          theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color:
                  theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRepeatDialog(
    BuildContext context,
    AppSettings settings,
  ) async {
    final result =
        await showDialog<int>(
      context: context,
      builder: (context) {
        return RadioGroup<int>(
          groupValue: settings.repeatMode,
          onChanged: (selected) {
            if (selected != null) {
              Navigator.of(context).pop(
                selected,
              );
            }
          },
          child: AlertDialog(
            title:
                const Text('Repeat'),
            content:
                Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                _repeatOption(
                  context,
                  0,
                  'Off',
                ),
                _repeatOption(
                  context,
                  1,
                  'Repeat All',
                ),
                _repeatOption(
                  context,
                  2,
                  'Repeat One',
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      ref
          .read(
            settingsProvider
                .notifier,
          )
          .setRepeatMode(result);
    }
  }

  Widget _repeatOption(
    BuildContext context,
    int value,
    String title,
  ) {
    return RadioListTile<int>(
      value: value,
      title: Text(title),
    );
  }

  String _repeatLabel(int value) {
    switch (value) {
      case 1:
        return 'Repeat all songs';

      case 2:
        return 'Repeat the current song';

      default:
        return 'Off';
    }
  }

  Future<void> _confirmReset(
    BuildContext context,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reset settings?',
          ),
          content: const Text(
            'All Nova Music settings will be restored to their defaults.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context)
                      .pop(false),
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context)
                      .pop(true),
              child:
                  const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    ref
        .read(
          settingsProvider
              .notifier,
        )
        .resetSettings();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Settings restored to defaults.',
        ),
      ),
    );
  }
}

class _SettingsCategory {
  const _SettingsCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _SidebarLabel
    extends StatelessWidget {
  const _SidebarLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        14,
        8,
        14,
        4,
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(
          fontWeight:
              FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SidebarItem
    extends StatelessWidget {
  const _SidebarItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _SettingsCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = selected
        ? theme.colorScheme.primary
        : theme
            .colorScheme
            .onSurfaceVariant;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: Material(
        color: selected
            ? theme.colorScheme.primary
                .withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(12),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  category.icon,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    category.title,
                    style: TextStyle(
                      color: color,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons
                        .chevron_right_rounded,
                    size: 20,
                    color: color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile
    extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding:
          const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: theme
                  .colorScheme
                  .primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme
                      .textTheme
                      .bodySmall
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
    );
  }
}