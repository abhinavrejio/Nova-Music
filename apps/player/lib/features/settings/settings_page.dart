import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/layout/page_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

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
                    title: 'Settings',
                    subtitle: 'Configure Nova Music the way you like.',
                  ),

                  SettingsSection(
                    title: 'General',
                    children: [
                      SettingsTile(
                        icon: Icons.play_circle_outline_rounded,
                        title: 'Playback',
                        subtitle: 'Playback behaviour',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.graphic_eq_rounded,
                        title: 'Audio',
                        subtitle: 'Output and quality',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.palette_outlined,
                        title: 'Appearance',
                        subtitle: 'Colors and interface',
                        onTap: () {},
                      ),
                    ],
                  ),

                  SettingsSection(
                    title: '✨ Personalization',
                    children: [
                      SettingsTile(
                        icon: Icons.home_outlined,
                        title: 'Home',
                        subtitle: 'Customize your Home screen',
                        onTap: () => context.push(
                          '/settings/personalization/home',
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.library_music_outlined,
                        title: 'Library',
                        subtitle: 'Customize Library',
                        onTap: () => context.push(
                          '/settings/personalization/library',
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.search_rounded,
                        title: 'Search',
                        subtitle: 'Customize Search',
                        onTap: () => context.push(
                          '/settings/personalization/search',
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.music_note_outlined,
                        title: 'Player',
                        subtitle: 'Customize Player',
                        onTap: () => context.push(
                          '/settings/personalization/player',
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.view_sidebar_outlined,
                        title: 'Sidebar',
                        subtitle: 'Customize Sidebar',
                        onTap: () => context.push(
                          '/settings/personalization/sidebar',
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.color_lens_outlined,
                        title: 'Theme',
                        subtitle: 'Customize Theme',
                        onTap: () => context.push(
                          '/settings/personalization/theme',
                        ),
                      ),
                    ],
                  ),

                  SettingsSection(
                    title: 'System',
                    children: [
                      SettingsTile(
                        icon: Icons.download_rounded,
                        title: 'Downloads',
                        subtitle: 'Manage downloads',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.build_outlined,
                        title: 'Advanced',
                        subtitle: 'Developer options',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About',
                        subtitle: 'Nova Music information',
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