import 'package:flutter/material.dart';

Future<ThemeMode?> showThemePickerDialog(
  BuildContext context,
  ThemeMode current,
) {
  ThemeMode selected = current;

  return showDialog<ThemeMode>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Choose Theme'),
            content: RadioGroup<ThemeMode>(
              groupValue: selected,
              onChanged: (ThemeMode? value) {
                if (value == null) return;
                setState(() => selected = value);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    title: Text('System'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    title: Text('Light'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    title: Text('Dark'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}