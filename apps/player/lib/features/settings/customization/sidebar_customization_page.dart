import 'package:flutter/material.dart';

class SidebarCustomizationPage extends StatelessWidget {
  const SidebarCustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sidebar Customization'),
      ),
      body: const Center(
        child: Text(
          'Sidebar Customization\nComing Soon',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}