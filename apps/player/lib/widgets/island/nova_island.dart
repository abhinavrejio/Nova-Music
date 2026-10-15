import 'dart:typed_data';

import 'package:flutter/material.dart';

class NovaIsland extends StatelessWidget {
  const NovaIsland({
    super.key,
    required this.title,
    required this.subtitle,
    this.artwork,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Uint8List? artwork;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 720,
          height: 120,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: artwork != null
                    ? Image.memory(
                        artwork!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 40,
                        ),
                      ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ],
                ),
              ),

              FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.play_arrow),
                label: const Text("Resume"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}