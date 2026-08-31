import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';

import 'widgets/settings_section.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/settings_tile.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              SettingsSection(
                title: "General",
                children: [
                  const SettingsTile(
                    icon: Icons.person_outline,
                    title: "Sign In",
                    subtitle: "Not signed in",
                  ),
                  SettingsSwitchTile(
                    icon: Icons.sync,
                    title: "Sync Library",
                    value: settings.syncLibrary,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).update(
                            settings.copyWith(
                              syncLibrary: value,
                            ),
                          );
                    },
                  ),
                  SettingsSwitchTile(
                    icon: Icons.history,
                    title: "Listening History",
                    value: settings.listeningHistory,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).update(
                            settings.copyWith(
                              listeningHistory: value,
                            ),
                          );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SettingsSection(
                title: "Appearance",
                children: [
                  SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: "Theme",
                    subtitle:
                        settings.themeMode.name.toUpperCase(),
                  ),
                  SettingsSwitchTile(
                    icon: Icons.blur_on,
                    title: "Liquid Glass",
                    value: settings.liquidGlass,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).update(
                            settings.copyWith(
                              liquidGlass: value,
                            ),
                          );
                    },
                  ),
                  SettingsSwitchTile(
                    icon: Icons.memory,
                    title: "Hardware Acceleration",
                    value: settings.hardwareAcceleration,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).update(
                            settings.copyWith(
                              hardwareAcceleration: value,
                            ),
                          );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const SettingsSection(
                title: "Library",
                children: [
                  SettingsTile(
                    icon: Icons.folder_outlined,
                    title: "Music Folders",
                  ),
                  SettingsTile(
                    icon: Icons.refresh,
                    title: "Scan Library",
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const SettingsSection(
                title: "Playback",
                children: [
                  SettingsTile(
                    icon: Icons.shuffle,
                    title: "Crossfade",
                  ),
                  SettingsTile(
                    icon: Icons.high_quality,
                    title: "Streaming Quality",
                  ),
                  SettingsTile(
                    icon: Icons.download,
                    title: "Download Quality",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}