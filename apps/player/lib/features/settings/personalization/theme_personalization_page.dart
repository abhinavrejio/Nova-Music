import 'package:flutter/material.dart';

class ThemePersonalizationPage extends StatelessWidget {
  const ThemePersonalizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Customization'),
      ),
      body: const Center(
        child: Text(
          'Theme Customization\nComing Soon',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}