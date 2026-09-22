import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/library/library_folder_provider.dart';
import '../../providers/library/library_provider.dart';
import '../../providers/audio/audio_player_provider.dart';
import '../../providers/playback/playback_mode_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_slider_tile.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/theme_picker_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final folders = ref.watch(libraryFolderProvider);
    final folderNotifier = ref.read(libraryFolderProvider.notifier);
    final shuffle = ref.watch(shuffleProvider);
    final repeatMode = ref.watch(repeatModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              SettingsSection(
                title: 'Appearance',
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Theme'),
                    subtitle: Text(settings.themeMode.name.toUpperCase()),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final mode = await showThemePickerDialog(
                        context,
                        settings.themeMode,
                      );

                      if (mode != null) {
                        await settingsNotifier.setThemeMode(mode);
                      }
                    },
                  ),
                  SettingsSwitchTile(
                    icon: Icons.blur_on_rounded,
                    title: 'Liquid Glass',
                    value: settings.liquidGlass,
                    onChanged: settingsNotifier.setLiquidGlass,
                  ),
                  SettingsSliderTile(
                    icon: Icons.zoom_in_rounded,
                    title: 'UI Scale',
                    value: settings.uiScale,
                    min: 0.9,
                    max: 1.2,
                    onChanged: settingsNotifier.setUiScale,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SettingsSection(
                title: 'Playback',
                children: [
                  SettingsSwitchTile(
                    icon: Icons.play_arrow_rounded,
                    title: 'Auto Play',
                    value: settings.autoPlay,
                    onChanged: settingsNotifier.setAutoPlay,
                  ),
                  SettingsSwitchTile(
                    icon: Icons.shuffle_rounded,
                    title: 'Shuffle',
                    value: shuffle,
                    onChanged: (enabled) {
                      if (enabled) {
                        ref.read(shuffleProvider.notifier).enable();
                      } else {
                        ref.read(shuffleProvider.notifier).disable();
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.repeat_rounded),
                    title: const Text('Repeat'),
                    subtitle: Text(_repeatLabel(repeatMode)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ref.read(repeatModeProvider.notifier).nextMode();
                    },
                  ),
                  SettingsSwitchTile(
                    icon: Icons.high_quality_rounded,
                    title: 'High Quality Audio',
                    value: settings.highQualityAudio,
                    onChanged: settingsNotifier.setHighQualityAudio,
                  ),
                  SettingsSliderTile(
                    icon: Icons.volume_up_rounded,
                    title: 'Volume Boost',
                    value: settings.volumeBoost,
                    min: 0,
                    max: 100,
                    onChanged: (value) async {
                      await settingsNotifier.setVolumeBoost(value);
                      await ref.read(audioPlayerProvider).setVolume(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SettingsSection(
                title: 'Library',
                children: [
                  ...folders.map(
                    (folder) => ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(folder.path),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await folderNotifier.removeFolder(folder.path);
                          await ref.read(libraryProvider.notifier).rescanAll();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Folder removed.')),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_rounded),
                    title: const Text('Add Folder'),
                    onTap: () async {
                      final path = await FilePicker.platform.getDirectoryPath();
                      if (path == null) return;

                      await folderNotifier.addFolder(path);
                      await ref.read(libraryProvider.notifier).scanFolder(path);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Folder added successfully.')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh_rounded),
                    title: const Text('Rescan Library'),
                    onTap: () async {
                      await ref.read(libraryProvider.notifier).rescanAll();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Library rescanned.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _repeatLabel(PlaybackRepeatMode mode) {
    switch (mode) {
      case PlaybackRepeatMode.off:
        return 'OFF';
      case PlaybackRepeatMode.all:
        return 'ALL';
      case PlaybackRepeatMode.one:
        return 'ONE';
    }
  }
}