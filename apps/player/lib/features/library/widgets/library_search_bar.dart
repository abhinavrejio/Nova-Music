import 'package:flutter/material.dart';

class LibrarySearchBar extends StatelessWidget {
  const LibrarySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search your library",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          filled: true,
        ),
      ),
    );
  }
}