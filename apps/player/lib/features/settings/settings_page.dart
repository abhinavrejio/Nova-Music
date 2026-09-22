import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/library/library_folder_provider.dart';
import '../../providers/library/library_provider.dart';
import '../../providers/settings_provider.dart';

import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';
import 'widgets/theme_picker_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    final folders = ref.watch(libraryFolderProvider);
    final folderNotifier = ref.read(libraryFolderProvider.notifier);

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

              //----------------------------------------------------------
              // GENERAL
              //----------------------------------------------------------

              const SettingsSection(
                title: "General",
                children: [
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: "Sign In",
                    subtitle: "Not signed in",
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //----------------------------------------------------------
              // APPEARANCE
              //----------------------------------------------------------

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
                    await settingsNotifier.setThemeMode(mode);
                  }
                },
              ),

              const SizedBox(height: 20),

              //----------------------------------------------------------
              // LIBRARY
              //----------------------------------------------------------

              SettingsSection(
                title: "Library",
                children: [

                  ...folders.map(
                    (folder) => ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(folder.path),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await folderNotifier.removeFolder(folder.path);

                          await ref
                              .read(libraryProvider.notifier)
                              .rescanAll();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Folder removed."),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text("Add Folder"),
                    onTap: () async {
                      final path =
                          await FilePicker.platform.getDirectoryPath();

                      if (path == null) return;

                      await folderNotifier.addFolder(path);

                      await ref
                          .read(libraryProvider.notifier)
                          .scanFolder(path);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Folder added successfully."),
                          ),
                        );
                      }
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: const Text("Rescan Library"),
                    onTap: () async {
                      await ref
                          .read(libraryProvider.notifier)
                          .rescanAll();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Library rescanned."),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //----------------------------------------------------------
              // PLAYBACK
              //----------------------------------------------------------

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