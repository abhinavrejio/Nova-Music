import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../providers/library/library_folder_provider.dart';
import '../../providers/library/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/adaptive_glass_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  static const _windowChannel = MethodChannel('nova/window');
  String _selected = 'General';
  final ScrollController _contentScrollController = ScrollController();
  AdaptiveGlassScan? _lastGlassScan;

  static const List<_SettingsCategory> _categories = [
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
      title: 'Offline Music',
      subtitle: 'Local music library',
      icon: Icons.library_music_rounded,
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
  void dispose() {
    _contentScrollController.dispose();
    super.dispose();
  }

  Future<void> _scanGlass(
    BuildContext context,
    SettingsNotifier notifier,
  ) async {
    final scan = await showDialog<AdaptiveGlassScan>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GlassBenchmarkDialog(
        logicalProcessors: Platform.numberOfProcessors,
        physicalSize: View.of(context).physicalSize,
        vsync: this,
      ),
    );
    if (scan == null || !mounted) return;
    notifier.applyAdaptiveGlassScan(scan.quality);
    setState(() => _lastGlassScan = scan);
  }

  Future<void> _setHardwareAcceleration(bool enabled) async {
    try {
      await _windowChannel.invokeMethod<void>(
        'setHardwareAcceleration',
        enabled,
      );
      ref.read(settingsProvider.notifier).setHardwareAcceleration(enabled);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'GPU preference will apply after restarting Nova Music.',
            ),
          ),
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not save GPU preference: ${error.message ?? 'Windows error'}',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the Windows GPU preference.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 950;

          if (!desktop) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: settings.liquidGlass ? settings.glassBlurSigma : 0,
                    sigmaY: settings.liquidGlass ? settings.glassBlurSigma : 0,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(
                        alpha: settings.liquidGlass
                            ? settings.glassSurfaceOpacity
                            : .94,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: .10),
                      ),
                    ),
                    child: _buildMobile(context, settings),
                  ),
                ),
              ),
            );
          }

          return Row(
            children: [
              _buildSidebar(context, settings),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: settings.liquidGlass
                            ? settings.glassBlurSigma
                            : 0,
                        sigmaY: settings.liquidGlass
                            ? settings.glassBlurSigma
                            : 0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface
                              .withValues(
                                alpha: settings.liquidGlass
                                    ? settings.glassSurfaceOpacity
                                    : .90,
                              ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: .10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .15),
                              blurRadius: 36,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: _buildContent(context, settings),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AppSettings settings) {
    final motion = settings.animationsEnabled;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: settings.liquidGlass ? settings.glassBlurSigma : 0,
            sigmaY: settings.liquidGlass ? settings.glassBlurSigma : 0,
          ),
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(
                alpha: settings.liquidGlass
                    ? settings.glassSurfaceOpacity
                    : .94,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: .10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .16),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NOVA',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text('Settings', style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                      children: [
                        const _SidebarLabel('SETTINGS'),
                        const SizedBox(height: 8),
                        for (final category in _categories)
                          _SidebarItem(
                            category: category,
                            selected: _selected == category.title,
                            animationsEnabled: motion,
                            onTap: () {
                              if (_selected == category.title) {
                                return;
                              }

                              setState(() {
                                _selected = category.title;
                              });
                            },
                          ),
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

  Widget _buildContent(BuildContext context, AppSettings settings) {
    final motion = settings.animationsEnabled;

    return SafeArea(
      child: SingleChildScrollView(
        controller: _contentScrollController,
        padding: const EdgeInsets.fromLTRB(42, 34, 42, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: AnimatedSwitcher(
              duration: motion
                  ? const Duration(milliseconds: 420)
                  : Duration.zero,
              reverseDuration: motion
                  ? const Duration(milliseconds: 280)
                  : Duration.zero,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide =
                    Tween<Offset>(
                      begin: const Offset(0.035, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    );

                final scale = Tween<double>(begin: 0.985, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slide,
                    child: ScaleTransition(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: child,
                    ),
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_selected),
                child: _buildSelectedPage(context, settings),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context, AppSettings settings) {
    final motion = settings.animationsEnabled;

    return SafeArea(
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 10, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selected,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  PopupMenuButton<String>(
                    initialValue: _selected,
                    tooltip: 'Settings sections',
                    onSelected: (value) {
                      if (_selected == value) {
                        return;
                      }

                      setState(() {
                        _selected = value;
                      });
                    },
                    itemBuilder: (context) {
                      return [
                        for (final category in _categories)
                          PopupMenuItem<String>(
                            value: category.title,
                            child: Row(
                              children: [
                                Icon(category.icon, size: 19),
                                const SizedBox(width: 10),
                                Text(category.title),
                              ],
                            ),
                          ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: AnimatedSwitcher(
                duration: motion
                    ? const Duration(milliseconds: 420)
                    : Duration.zero,
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  final slide =
                      Tween<Offset>(
                        begin: const Offset(0, 0.025),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_selected),
                  child: _buildSelectedPage(context, settings),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPage(BuildContext context, AppSettings settings) {
    switch (_selected) {
      case 'General':
        return _general(context, settings);
      case 'Playback & Audio':
        return _playbackAudio(context, settings);
      case 'Appearance':
        return _appearance(context, settings);
      case 'Search':
        return _search(context, settings);
      case 'Personalization':
        return _personalization(context);
      case 'Offline Music':
        return _downloads(context);
      case 'Advanced':
        return _advanced(context, settings);
      case 'About':
        return _about(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _general(BuildContext context, AppSettings settings) {
    return _page(
      context,
      icon: Icons.settings_rounded,
      title: 'General',
      subtitle: 'Configure how Nova Music behaves.',
      children: [
        _sectionTitle(
          context,
          'STARTUP',
          'Control what Nova does when you start using it.',
        ),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon: Icons.play_arrow_rounded,
              title: 'Autoplay',
              subtitle: 'Continue playback automatically.',
              value: settings.autoPlay,
              onChanged: ref.read(settingsProvider.notifier).setAutoPlay,
            ),
          ],
        ),
      ],
    );
  }

  Widget _playbackAudio(BuildContext context, AppSettings settings) {
    final notifier = ref.read(settingsProvider.notifier);

    return _page(
      context,
      icon: Icons.play_circle_outline_rounded,
      title: 'Playback & Audio',
      subtitle: 'Control playback, controls, and sound.',
      children: [
        _sectionTitle(
          context,
          'PLAYBACK',
          'Control how songs are played and what happens next.',
        ),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon: Icons.play_arrow_rounded,
              title: 'Autoplay',
              subtitle: 'Continue with another song when the queue ends.',
              value: settings.autoPlay,
              onChanged: notifier.setAutoPlay,
            ),
            _switchTile(
              context,
              icon: Icons.swap_horiz_rounded,
              title: 'Crossfade',
              subtitle:
                  'Blend the end of one song into the beginning of the next.',
              value: settings.crossfadeEnabled,
              onChanged: notifier.setCrossfadeEnabled,
            ),
            if (settings.crossfadeEnabled)
              _crossfadeDurationTile(context, settings, notifier),
            _switchTile(
              context,
              icon: Icons.shuffle_rounded,
              title: 'Shuffle',
              subtitle: 'Play queued songs in a random order.',
              value: settings.shuffle,
              onChanged: notifier.setShuffle,
            ),
            _navigationTile(
              context,
              icon: Icons.repeat_rounded,
              title: 'Repeat',
              subtitle: _repeatLabel(settings.repeatMode),
              onTap: () => _showRepeatDialog(context, settings),
            ),
          ],
        ),
        _sectionTitle(
          context,
          'MINI PLAYER',
          'Choose which playback controls are visible.',
        ),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon: Icons.shuffle_rounded,
              title: 'Show Shuffle',
              subtitle: 'Show the shuffle control in the mini player.',
              value: settings.miniPlayerShowShuffle,
              onChanged: notifier.setMiniPlayerShowShuffle,
            ),
            _switchTile(
              context,
              icon: Icons.repeat_rounded,
              title: 'Show Repeat',
              subtitle: 'Show the repeat control in the mini player.',
              value: settings.miniPlayerShowRepeat,
              onChanged: notifier.setMiniPlayerShowRepeat,
            ),
            _switchTile(
              context,
              icon: Icons.queue_music_rounded,
              title: 'Show Queue',
              subtitle: 'Show the queue button in the mini player.',
              value: settings.miniPlayerShowQueue,
              onChanged: notifier.setMiniPlayerShowQueue,
            ),
          ],
        ),
        _sectionTitle(context, 'AUDIO', 'Control audio quality.'),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon: Icons.high_quality_rounded,
              title: 'High Quality Audio',
              subtitle: 'Prefer the highest quality available for local files.',
              value: settings.highQualityAudio,
              onChanged: notifier.setHighQualityAudio,
            ),
          ],
        ),
      ],
    );
  }

  Widget _appearance(BuildContext context, AppSettings settings) {
    final notifier = ref.read(settingsProvider.notifier);

    const colors = [
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
      subtitle: 'Customize Nova Music appearance and navigation.',
      children: [
        _sectionTitle(
          context,
          'APPEARANCE',
          'Customize the visual style of Nova Music.',
        ),
        _settingsCard(
          context,
          children: [
            _themeTile(context, settings),
            _switchTile(
              context,
              icon: Icons.dark_mode_rounded,
              title: 'AMOLED Black',
              subtitle: 'Use true black backgrounds in dark mode.',
              value: settings.amoledBlack,
              onChanged: notifier.setAmoledBlack,
            ),
            _switchTile(
              context,
              icon: Icons.animation_rounded,
              title: 'Animations',
              subtitle: 'Enable Nova interface and page animations.',
              value: settings.animationsEnabled,
              onChanged: notifier.setAnimationsEnabled,
            ),
          ],
        ),
        _sectionTitle(
          context,
          'BACKGROUND STYLE',
          'Choose what appears behind every page.',
        ),
        _settingsCard(
          context,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: DropdownButtonFormField<BackgroundStyle>(
                key: ValueKey(settings.backgroundStyle),
                initialValue: settings.backgroundStyle,
                dropdownColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
                decoration: const InputDecoration(
                  labelText: 'Background',
                  prefixIcon: Icon(Icons.wallpaper_rounded),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: BackgroundStyle.gradient,
                    child: Text('Animated gradient'),
                  ),
                  DropdownMenuItem(
                    value: BackgroundStyle.albumArtwork,
                    child: Text('Current album artwork'),
                  ),
                  DropdownMenuItem(
                    value: BackgroundStyle.wallpaper,
                    child: Text('My wallpaper'),
                  ),
                  DropdownMenuItem(
                    value: BackgroundStyle.solidColor,
                    child: Text('Solid color'),
                  ),
                ],
                onChanged: settings.amoledBlack
                    ? null
                    : (value) {
                        if (value != null) notifier.setBackgroundStyle(value);
                      },
              ),
            ),
            if (settings.backgroundStyle == BackgroundStyle.gradient &&
                !settings.amoledBlack)
              _switchTile(
                context,
                icon: Icons.motion_photos_on_rounded,
                title: 'Animate Gradient',
                subtitle: 'Move the selected color softly behind every page.',
                value: settings.backgroundGradient,
                onChanged: notifier.setBackgroundGradient,
              ),
            if (!settings.amoledBlack &&
                (settings.backgroundStyle == BackgroundStyle.gradient ||
                    settings.backgroundStyle == BackgroundStyle.solidColor))
              _backgroundColorPicker(context, settings),
            if (!settings.amoledBlack &&
                settings.backgroundStyle == BackgroundStyle.wallpaper)
              _wallpaperPicker(context, settings),
            if (settings.amoledBlack)
              const _InfoTile(
                icon: Icons.dark_mode_rounded,
                title: 'AMOLED background active',
                subtitle: 'The app background stays pure black while this mode is on.',
              ),
          ],
        ),
        _sectionTitle(
          context,
          'LIQUID GLASS',
          'Tune blur strength and let Nova recommend a quality for this device.',
        ),
        _glassSettings(context, settings, notifier),
        _sectionTitle(
          context,
          'ACCENT COLOR',
          'Choose the color used for highlights and selected controls.',
        ),
        _settingsCard(
          context,
          children: [_accentColorTile(context, colors, settings)],
        ),
        _sectionTitle(context, 'UI SCALE', 'Resize the Nova interface.'),
        _settingsCard(context, children: [_scaleTile(context, settings)]),
        _sectionTitle(context, 'SIDEBAR', 'Customize desktop navigation.'),
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon: Icons.view_sidebar_rounded,
              title: 'Compact Sidebar',
              subtitle: 'Use a narrower desktop navigation sidebar.',
              value: settings.compactSidebar,
              onChanged: notifier.setCompactSidebar,
            ),
          ],
        ),
      ],
    );
  }

  Widget _search(BuildContext context, AppSettings settings) {
    final notifier = ref.read(settingsProvider.notifier);

    return _page(
      context,
      icon: Icons.search_rounded,
      title: 'Search',
      subtitle: 'Choose what Nova shows in search results.',
      children: [
        _settingsCard(
          context,
          children: [
            _switchTile(
              context,
              icon: Icons.music_note_rounded,
              title: 'Songs',
              subtitle: 'Show songs in search results.',
              value: settings.searchShowSongs,
              onChanged: notifier.setSearchShowSongs,
            ),
            _switchTile(
              context,
              icon: Icons.queue_music_rounded,
              title: 'Playlists',
              subtitle: 'Show playlists in search results.',
              value: settings.searchShowPlaylists,
              onChanged: notifier.setSearchShowPlaylists,
            ),
          ],
        ),
      ],
    );
  }

  Widget _personalization(BuildContext context) {
    return _page(
      context,
      icon: Icons.tune_rounded,
      title: 'Personalization',
      subtitle: 'Customize individual parts of Nova Music.',
      children: [
        _settingsCard(
          context,
          children: [
            _navigationTile(
              context,
              icon: Icons.home_outlined,
              title: 'Home',
              subtitle: 'Choose and arrange sections shown on Home.',
              onTap: () => context.push('/settings/personalization/home'),
            ),
            _navigationTile(
              context,
              icon: Icons.library_music_outlined,
              title: 'Library',
              subtitle: 'Customize your library layout and sections.',
              onTap: () => context.push('/settings/personalization/library'),
            ),
            _navigationTile(
              context,
              icon: Icons.search_rounded,
              title: 'Search',
              subtitle: 'Customize Search.',
              onTap: () => context.push('/settings/personalization/search'),
            ),
            _navigationTile(
              context,
              icon: Icons.music_note_outlined,
              title: 'Player',
              subtitle: 'Customize the player.',
              onTap: () => context.push('/settings/personalization/player'),
            ),
            _navigationTile(
              context,
              icon: Icons.view_sidebar_outlined,
              title: 'Sidebar',
              subtitle: 'Customize navigation.',
              onTap: () => context.push('/settings/personalization/sidebar'),
            ),
            _navigationTile(
              context,
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: 'Customize the theme and appearance.',
              onTap: () => context.push('/settings/personalization/theme'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _downloads(BuildContext context) {
    final folders = ref.watch(libraryFolderProvider);
    final songs = ref.watch(libraryProvider);

    return _page(
      context,
      icon: Icons.library_music_rounded,
      title: 'Offline Music',
      subtitle: 'Manage your local music library.',
      children: [
        _sectionTitle(
          context,
          'OFFLINE MUSIC',
          'Manage your local music library.',
        ),
        _settingsCard(
          context,
          children: [
            _navigationTile(
              context,
              icon: Icons.create_new_folder_outlined,
              title: 'Add Music Folder',
              subtitle: folders.isEmpty
                  ? 'Choose a folder containing your music.'
                  : '${folders.length} music folder${folders.length == 1 ? '' : 's'} added.',
              onTap: _pickMusicFolder,
            ),
            _navigationTile(
              context,
              icon: Icons.sync_rounded,
              title: 'Scan Music',
              subtitle: '${songs.length} songs currently in your library.',
              onTap: () async {
                await ref.read(libraryProvider.notifier).rescanAll();

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Music scan complete. ${ref.read(libraryProvider).length} songs found.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        if (folders.isNotEmpty) ...[
          _sectionTitle(
            context,
            'MUSIC FOLDERS',
            'Nova will rescan these folders when the library starts.',
          ),
          _settingsCard(
            context,
            children: [
              for (final folder in folders) _folderTile(context, folder.path),
            ],
          ),
        ],
      ],
    );
  }

  Widget _folderTile(BuildContext context, String path) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        child: Row(
          children: [
            _tileIcon(context, Icons.folder_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                path,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
            IconButton(
              tooltip: 'Remove folder',
              icon: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
              ),
              onPressed: () async {
                await ref
                    .read(libraryFolderProvider.notifier)
                    .removeFolder(path);
                await ref.read(libraryProvider.notifier).rescanAll();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMusicFolder() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select your music folder',
    );

    if (path == null || path.trim().isEmpty) {
      return;
    }

    await ref.read(libraryFolderProvider.notifier).addFolder(path);
    await ref.read(libraryProvider.notifier).rescanAll();

    if (!mounted) return;

    final count = ref.read(libraryProvider).length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Music scan complete. $count songs found.')),
    );
  }

  Widget _backgroundColorPicker(BuildContext context, AppSettings settings) {
    const colors = [
      0xFFFF6B5F,
      0xFFFF9B71,
      0xFF4D9FFF,
      0xFF55D6BE,
      0xFFA879FF,
      0xFFFF5F9E,
      0xFFFFB347,
      0xFF5FD7FF,
      0xFF8DDC65,
    ];
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settings.backgroundStyle == BackgroundStyle.gradient
                ? 'Gradient color'
                : 'Background color',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose the tint used by the animated gradient or solid background.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final value in colors)
                Semantics(
                  button: true,
                  label:
                      'Background color ${Color(value).toARGB32().toRadixString(16)}',
                  selected: value == settings.backgroundColorValue,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => notifier.setBackgroundColor(value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(value),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: value == settings.backgroundColorValue
                              ? Colors.white
                              : Colors.white.withValues(alpha: .24),
                          width: value == settings.backgroundColorValue
                              ? 2.5
                              : 1,
                        ),
                        boxShadow: value == settings.backgroundColorValue
                            ? [
                                BoxShadow(
                                  color: Color(value).withValues(alpha: .36),
                                  blurRadius: 14,
                                ),
                              ]
                            : null,
                      ),
                      child: value == settings.backgroundColorValue
                          ? const Icon(Icons.check_rounded, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _wallpaperPicker(BuildContext context, AppSettings settings) {
    final notifier = ref.read(settingsProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (settings.wallpaperPath != null && !kIsWeb) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 150,
                child: Image.file(
                  File(settings.wallpaperPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text('Wallpaper file could not be previewed.'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          _navigationTile(
            context,
            icon: Icons.image_rounded,
            title: settings.wallpaperPath == null
                ? 'Choose wallpaper'
                : 'Change wallpaper',
            subtitle: settings.wallpaperPath == null
                ? 'Select an image to fill the app background.'
                : settings.wallpaperPath!.split(Platform.pathSeparator).last,
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: false,
              );
              final path = result != null && result.files.isNotEmpty
                  ? result.files.first.path
                  : null;
              if (path != null) notifier.setWallpaperPath(path);
            },
          ),
          if (settings.wallpaperPath != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => notifier.setWallpaperPath(null),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Remove wallpaper'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _glassSettings(
    BuildContext context,
    AppSettings settings,
    SettingsNotifier notifier,
  ) {
    final theme = Theme.of(context);
    return _settingsCard(
      context,
      children: [
        _switchTile(
          context,
          icon: Icons.blur_on_rounded,
          title: 'Liquid Glass',
          subtitle: 'Use translucent floating surfaces across Nova.',
          value: settings.liquidGlass,
          onChanged: notifier.setLiquidGlass,
        ),
        if (settings.liquidGlass)
          _switchTile(
            context,
            icon: Icons.auto_awesome_rounded,
            title: 'Adaptive Glass',
            subtitle: 'Measure a short glass preview and recommend a quality.',
            value: settings.adaptiveGlass,
            onChanged: (enabled) {
              if (enabled) {
                _scanGlass(context, notifier);
              } else {
                notifier.setAdaptiveGlass(false);
              }
            },
          ),
        if (settings.liquidGlass)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<GlassQuality>(
                  key: ValueKey(settings.glassQuality),
                  initialValue: settings.glassQuality,
                  dropdownColor: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                  decoration: const InputDecoration(
                    labelText: 'Glass quality',
                    prefixIcon: Icon(Icons.blur_circular_rounded),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: GlassQuality.low,
                      child: Text('Low · lighter blur'),
                    ),
                    DropdownMenuItem(
                      value: GlassQuality.balanced,
                      child: Text('Balanced'),
                    ),
                    DropdownMenuItem(
                      value: GlassQuality.high,
                      child: Text('High · richer blur'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) notifier.setGlassQuality(value);
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _scanGlass(context, notifier),
                  icon: const Icon(Icons.speed_rounded),
                  label: const Text('Benchmark glass rendering'),
                ),
                if (_lastGlassScan case final scan?) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Recommended: ${scan.quality.name} · ${scan.description}. Frame timings include Flutter raster work; GPU model and utilization are not exposed.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _advanced(BuildContext context, AppSettings settings) {
    return _page(
      context,
      icon: Icons.build_outlined,
      title: 'Advanced',
      subtitle: 'Advanced Nova Music configuration.',
      children: [
        _sectionTitle(
          context,
          'PERFORMANCE',
          'Control system-level interface behavior.',
        ),
        _settingsCard(
          context,
          children: [
            if (!kIsWeb && Platform.isWindows)
              _switchTile(
                context,
                icon: Icons.speed_rounded,
                title: 'Hardware Acceleration',
                subtitle: settings.hardwareAcceleration
                    ? 'On: asks Windows to prefer a high-performance GPU. Flutter stays GPU accelerated in either mode; restart Nova Music to apply.'
                    : 'Off: uses Flutter’s default GPU choice. Hardware rendering remains enabled where supported; restart Nova Music to apply.',
                value: settings.hardwareAcceleration,
                onChanged: _setHardwareAcceleration,
              ),
          ],
        ),
        _sectionTitle(
          context,
          'RESET',
          'Restore Nova Music settings to their defaults.',
        ),
        _settingsCard(
          context,
          children: [
            _dangerTile(
              context,
              icon: Icons.restore_rounded,
              title: 'Reset All Settings',
              subtitle: 'Restore all settings to their default values.',
              onTap: () => _confirmReset(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _about(BuildContext context) {
    final platform = kIsWeb ? 'Web' : defaultTargetPlatform.name;
    final dartVersion = kIsWeb
        ? 'Browser runtime'
        : Platform.version.split(' ').first;
    final buildMode = kDebugMode
        ? 'Debug'
        : kProfileMode
        ? 'Profile'
        : 'Release';

    return _page(
      context,
      icon: Icons.info_outline_rounded,
      title: 'About',
      subtitle: 'The details behind your Nova Music build.',
      children: [
        _settingsCard(
          context,
          children: [
            const _InfoTile(
              icon: Icons.bolt_rounded,
              title: 'Nova Music',
              subtitle: 'A personal player for your local music library.',
            ),
            const _InfoTile(
              icon: Icons.sell_outlined,
              title: 'App version',
              subtitle: '1.0.0 · build 1',
            ),
            _InfoTile(
              icon: Icons.devices_rounded,
              title: 'Runtime',
              subtitle: '$platform · $buildMode mode',
            ),
            _InfoTile(
              icon: Icons.code_rounded,
              title: 'Dart runtime',
              subtitle: dartVersion,
            ),
            _InfoTile(
              icon: Icons.memory_rounded,
              title: 'Graphics renderer',
              subtitle: kIsWeb
                  ? 'GPU rendering is managed by the browser.'
                  : defaultTargetPlatform == TargetPlatform.windows
                  ? 'Skia rendering · Windows prefers a high-performance GPU when available.'
                  : 'Flutter uses the GPU renderer selected by this platform.',
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
      key: ValueKey(title),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  Widget _sectionTitle(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(BuildContext context, {required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == children.length - 1 ? 0 : 10,
              ),
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: children[i],
              ),
            ),
        ],
      ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _tileIcon(context, icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crossfadeDurationTile(
    BuildContext context,
    AppSettings settings,
    SettingsNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final seconds = settings.crossfadeDurationSeconds.clamp(1, 12);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tileIcon(context, Icons.timer_outlined),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Crossfade Duration',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$seconds s',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            min: 1,
            max: 12,
            divisions: 11,
            value: seconds.toDouble(),
            label: '$seconds seconds',
            onChanged: (value) =>
                notifier.setCrossfadeDurationSeconds(value.round()),
          ),
          Text(
            'The next song starts before the current song finishes.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _tileIcon(context, icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tileIcon(BuildContext context, IconData icon) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 19, color: theme.colorScheme.primary),
    );
  }

  Widget _themeTile(BuildContext context, AppSettings settings) {
    final notifier = ref.read(settingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tileIcon(context, Icons.dark_mode_outlined),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theme',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Choose how Nova follows your display theme.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_rounded),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded),
                  label: Text('Dark'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded),
                  label: Text('Light'),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  notifier.setThemeMode(selection.first);
                }
              },
            ),
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
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tileIcon(context, Icons.color_lens_outlined),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accent Color',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Used for highlights and selected controls.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
            children: colors.map((value) {
              final selected = value == settings.accentColorValue;

              return GestureDetector(
                onTap: () => notifier.setAccentColor(value),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  scale: selected ? 1.08 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Color(value),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Color(value).withValues(alpha: 0.35),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              key: ValueKey('selected'),
                              color: Colors.white,
                              size: 20,
                            )
                          : const SizedBox(key: ValueKey('empty')),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _scaleTile(BuildContext context, AppSettings settings) {
    final notifier = ref.read(settingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        children: [
          Row(
            children: [
              _tileIcon(context, Icons.zoom_in_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UI Scale',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        '${(settings.uiScale * 100).round()}% interface scale',
                        key: ValueKey(settings.uiScale),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => notifier.setUiScale(1.0),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            min: AppSettings.minUiScale,
            max: AppSettings.maxUiScale,
            value: settings.uiScale
                .clamp(AppSettings.minUiScale, AppSettings.maxUiScale)
                .toDouble(),
            label: '${(settings.uiScale * 100).round()}%',
            onChanged: notifier.setUiScale,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('90%'), Text('100%'), Text('110%'), Text('120%')],
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _tileIcon(context, icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.error),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRepeatDialog(
    BuildContext context,
    AppSettings settings,
  ) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return RadioGroup<int>(
          groupValue: settings.repeatMode,
          onChanged: (selected) {
            if (selected != null) {
              Navigator.of(context).pop(selected);
            }
          },
          child: AlertDialog(
            title: const Text('Repeat'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _repeatOption(context, 0, 'Off'),
                _repeatOption(context, 1, 'Repeat All'),
                _repeatOption(context, 2, 'Repeat One'),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      ref.read(settingsProvider.notifier).setRepeatMode(result);
    }
  }

  Widget _repeatOption(BuildContext context, int value, String title) {
    return RadioListTile<int>(value: value, title: Text(title));
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

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset settings?'),
          content: const Text(
            'All Nova Music settings will be restored to their defaults.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    ref.read(settingsProvider.notifier).resetSettings();
    if (!kIsWeb && Platform.isWindows) {
      try {
        await _windowChannel.invokeMethod<void>(
          'setHardwareAcceleration',
          AppSettings.defaults.hardwareAcceleration,
        );
      } catch (_) {
        // Keep the settings reset complete even if the native preference fails.
      }
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings restored to defaults.')),
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

class _SidebarLabel extends StatelessWidget {
  const _SidebarLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.category,
    required this.selected,
    required this.animationsEnabled,
    required this.onTap,
  });

  final _SettingsCategory category;
  final bool selected;
  final bool animationsEnabled;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = widget.selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _hovered = true);
        },
        onExit: (_) {
          setState(() => _hovered = false);
        },
        child: AnimatedContainer(
          duration: widget.animationsEnabled
              ? const Duration(milliseconds: 240)
              : Duration.zero,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: widget.selected
                ? theme.colorScheme.primary.withValues(alpha: 0.13)
                : _hovered
                ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    AnimatedScale(
                      duration: widget.animationsEnabled
                          ? const Duration(milliseconds: 240)
                          : Duration.zero,
                      curve: Curves.easeOutBack,
                      scale: widget.selected ? 1.10 : 1.0,
                      child: Icon(widget.category.icon, size: 20, color: color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: widget.animationsEnabled
                                ? const Duration(milliseconds: 200)
                                : Duration.zero,
                            style: TextStyle(
                              color: color,
                              fontWeight: widget.selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            child: Text(widget.category.title),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.category.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSlide(
                      duration: widget.animationsEnabled
                          ? const Duration(milliseconds: 220)
                          : Duration.zero,
                      curve: Curves.easeOutCubic,
                      offset: widget.selected
                          ? Offset.zero
                          : const Offset(-0.15, 0),
                      child: AnimatedOpacity(
                        duration: widget.animationsEnabled
                            ? const Duration(milliseconds: 180)
                            : Duration.zero,
                        opacity: widget.selected ? 1 : 0,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
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

class _InfoTile extends StatelessWidget {
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _GlassBenchmarkDialog extends StatefulWidget {
  const _GlassBenchmarkDialog({
    required this.logicalProcessors,
    required this.physicalSize,
    required this.vsync,
  });

  final int logicalProcessors;
  final Size physicalSize;
  final TickerProvider vsync;

  @override
  State<_GlassBenchmarkDialog> createState() => _GlassBenchmarkDialogState();
}

class _GlassBenchmarkDialogState extends State<_GlassBenchmarkDialog> {
  final List<Duration> _rasterDurations = [];
  late final AnimationController _controller;
  Timer? _finishTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addTimingsCallback(_recordTimings);
    _controller = AnimationController(
      vsync: widget.vsync,
      duration: const Duration(milliseconds: 1800),
    )..addStatusListener(_handleAnimationStatus);
    _controller.forward();
  }

  void _recordTimings(List<FrameTiming> timings) {
    _rasterDurations.addAll(timings.map((timing) => timing.rasterDuration));
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Let Flutter deliver the final raster timing batch before reading it.
      _finishTimer = Timer(const Duration(milliseconds: 120), _finishBenchmark);
    }
  }

  void _finishBenchmark() {
    if (!mounted) return;
    WidgetsBinding.instance.removeTimingsCallback(_recordTimings);
    final scan = AdaptiveGlassService.fromRasterTimings(
      logicalProcessors: widget.logicalProcessors,
      physicalSize: widget.physicalSize,
      rasterDurations: _rasterDurations,
    );
    Navigator.of(context).pop(scan);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Glass performance check'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 144,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-1 + t, -1),
                              end: Alignment(1 - t, 1),
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: .8),
                                theme.colorScheme.tertiary.withValues(
                                  alpha: .8,
                                ),
                                theme.colorScheme.secondary.withValues(
                                  alpha: .8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment(-.68 + t * 1.36, -.25),
                          child: _benchmarkGlassSurface(theme, 1),
                        ),
                        Align(
                          alignment: Alignment(.68 - t * 1.36, .25),
                          child: _benchmarkGlassSurface(theme, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            const Text(
              'Running a brief animated blur preview and measuring Flutter raster frame times. This does not identify your GPU.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _benchmarkGlassSurface(ThemeData theme, int seed) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        width: 112,
        height: 92,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: .38),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: .34),
            width: 1.2,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: .32),
              theme.colorScheme.surface.withValues(alpha: .16),
            ],
          ),
        ),
        child: Icon(
          seed == 1 ? Icons.blur_on_rounded : Icons.circle,
          color: Colors.white.withValues(alpha: .82),
          size: seed == 1 ? 28 : 18,
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _finishTimer?.cancel();
    WidgetsBinding.instance.removeTimingsCallback(_recordTimings);
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }
}
