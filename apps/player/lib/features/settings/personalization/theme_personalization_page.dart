import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings_provider.dart';

class ThemePersonalizationPage extends ConsumerWidget {
  const ThemePersonalizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Make Nova feel like yours',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a theme and tune the interface.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                RadioGroup<ThemeMode>(
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) notifier.setThemeMode(value);
                  },
                  child: const Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.system,
                        title: Text('System'),
                        subtitle: Text('Follow your device setting'),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.dark,
                        title: Text('Dark'),
                        subtitle: Text('Nova night colors'),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.light,
                        title: Text('Light'),
                        subtitle: Text('A brighter interface'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile.adaptive(
              value: settings.liquidGlass,
              title: const Text('Liquid Glass'),
              subtitle: const Text('Use translucent surfaces where available.'),
              onChanged: notifier.setLiquidGlass,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Interface Scale'),
              subtitle: Slider(
                value: settings.uiScale,
                min: 0.9,
                max: 1.2,
                divisions: 6,
                label: '${(settings.uiScale * 100).round()}%',
                onChanged: notifier.setUiScale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
