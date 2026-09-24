import 'package:flutter/material.dart';

class PlayerPersonalizationPage extends StatelessWidget {
  const PlayerPersonalizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Customization'),
      ),
      body: const Center(
        child: Text(
          'Player Customization\nComing Soon',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}