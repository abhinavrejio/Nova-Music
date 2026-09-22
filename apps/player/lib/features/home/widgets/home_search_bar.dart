import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/colors.dart';
import '../../../design/radii.dart';
import '../../../design/spacing.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: () => context.go('/search'),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Text(
                    "Search songs, artists, albums...",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),

                Icon(
                  Icons.keyboard_command_key_rounded,
                  size: 18,
                  color: Colors.grey.shade600,
                ),

                const SizedBox(width: 4),

                Text(
                  "K",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}