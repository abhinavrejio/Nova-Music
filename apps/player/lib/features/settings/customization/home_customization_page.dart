import 'package:flutter/material.dart';

class HomeCustomizationPage extends StatelessWidget {
  const HomeCustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Customization"),
      ),
      body: const Center(
        child: Text(
          "Home Customization\nComing Soon",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}