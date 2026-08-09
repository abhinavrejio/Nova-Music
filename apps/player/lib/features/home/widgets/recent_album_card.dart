import 'package:flutter/material.dart';

class RecentAlbumCard extends StatelessWidget {
  final String title;

  const RecentAlbumCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}