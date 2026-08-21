import 'package:flutter/material.dart';

class ContinueListeningCard extends StatelessWidget {
  const ContinueListeningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6C4CF1),
              Color(0xFF8D73FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),

            const Text(
              "Continue Listening",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Blinding Lights",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "The Weeknd",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),

            const Spacer(),

            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text("Resume"),
            ),
          ],
        ),
      ),
    );
  }
}