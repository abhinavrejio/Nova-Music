import 'package:flutter/material.dart';

Future<ThemeMode?> showThemePickerDialog(
  BuildContext context,
  ThemeMode current,
) {
  return showDialog<ThemeMode>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text("Choose Theme"),
        children: [
          RadioListTile<ThemeMode>(
            title: const Text("System"),
            value: ThemeMode.system,
            groupValue: current,
            onChanged: (value) {
              Navigator.pop(context, value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text("Light"),
            value: ThemeMode.light,
            groupValue: current,
            onChanged: (value) {
              Navigator.pop(context, value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text("Dark"),
            value: ThemeMode.dark,
            groupValue: current,
            onChanged: (value) {
              Navigator.pop(context, value);
            },
          ),
        ],
      );
    },
  );
}