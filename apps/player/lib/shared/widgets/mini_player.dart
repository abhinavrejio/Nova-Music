import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Colors.deepPurple,
      child: const Center(
        child: Text(
          'Mini Player',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}