import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';

import 'widgets/settings_section.dart';
import 'widgets/settings_slider_tile.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/settings_tile.dart';
import 'widgets/theme_picker_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              /// GENERAL
              SettingsSection(
                title: "General",
                children: const [
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: "Sign In",
                    subtitle: "Not signed in",
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// APPEARANCE
              SettingsTile(
  icon: Icons.dark_mode_outlined,
  title: "Theme",
  subtitle: settings.themeMode.name.toUpperCase(),
  onTap: () async {
    final mode = await showThemePickerDialog(
      context,
      settings.themeMode,
    );

    if (mode != null) {
      await notifier.setThemeMode(mode);
    }
  },
),

              /// LIBRARY
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

              /// PLAYBACK
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