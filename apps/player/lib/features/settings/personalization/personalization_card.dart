import 'package:flutter/material.dart';

class PersonalizationCard extends StatelessWidget {
  const PersonalizationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.visible,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool visible;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        child: Row(
          children: [
            const Icon(Icons.drag_indicator_rounded),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            Switch(
              value: visible,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}