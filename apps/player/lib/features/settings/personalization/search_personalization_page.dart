import 'package:flutter/material.dart';

class SearchPersonalizationPage extends StatelessWidget {
  const SearchPersonalizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Customization'),
      ),
      body: const Center(
        child: Text(
          'Search Customization\nComing Soon',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}