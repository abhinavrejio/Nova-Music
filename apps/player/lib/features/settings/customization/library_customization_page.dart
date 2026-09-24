import 'package:flutter/material.dart';

class LibraryCustomizationPage extends StatelessWidget {
  const LibraryCustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Customization"),
      ),
      body: const Center(
        child: Text(
          "Library Customization\nComing Soon",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}