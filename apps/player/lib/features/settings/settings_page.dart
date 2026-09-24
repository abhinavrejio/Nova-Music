import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/layout/page_header.dart';
import '../../widgets/settings/settings_group.dart';
import '../../widgets/settings/settings_section.dart';
import '../../widgets/settings/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PageHeader(
                    title: "Settings",
                    subtitle: "Configure Nova the way you like.",
                  ),

                  const SizedBox(height: 40),

                  const SettingsSection(
                    title: "General",
                  ),

                  SettingsGroup(
                    children: [
                      SettingsTile(
                        icon: Icons.play_circle_outline,
                        title: "Playback",
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.graphic_eq,
                        title: "Audio",
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.palette_outlined,
                        title: "Appearance",
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  const SettingsSection(
                    title: "✨ Personalization",
                  ),

                  SettingsGroup(
                    children: [
                      SettingsTile(
                        icon: Icons.home_outlined,
                        title: "Home",
                        onTap: () => context.push(
                          "/settings/customization/home",
                        ),
                      ),

                      SettingsTile(
                        icon: Icons.library_music_outlined,
                        title: "Library",
                        onTap: () => context.push(
                          "/settings/customization/library",
                        ),
                      ),

                      SettingsTile(
                        icon: Icons.search,
                        title: "Search",
                        onTap: () => context.push(
                          "/settings/customization/search",
                        ),
                      ),

                      SettingsTile(
                        icon: Icons.music_note_outlined,
                        title: "Player",
                        onTap: () => context.push(
                          "/settings/customization/player",
                        ),
                      ),

                      SettingsTile(
                        icon: Icons.view_sidebar_outlined,
                        title: "Sidebar",
                        onTap: () => context.push(
                          "/settings/customization/sidebar",
                        ),
                      ),

                      SettingsTile(
                        icon: Icons.color_lens_outlined,
                        title: "Theme",
                        onTap: () => context.push(
                          "/settings/customization/theme",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  const SettingsSection(
                    title: "System",
                  ),

                  SettingsGroup(
                    children: [
                      SettingsTile(
                        icon: Icons.download_outlined,
                        title: "Downloads",
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.build_outlined,
                        title: "Advanced",
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.info_outline,
                        title: "About",
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}