import 'package:flutter/material.dart';

class LibraryPersonalizationPage extends StatelessWidget {
  const LibraryPersonalizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Personalization'),
      ),
      body: const Center(
        child: Text(
          'Library Personalization\nComing Soon',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}