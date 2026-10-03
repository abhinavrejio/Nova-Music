import 'package:flutter/material.dart';

import '../../design/animations.dart';
import '../../design/colors.dart';
import '../../design/radii.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = "Search",
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.height = 54,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool readOnly;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double height;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppAnimations.medium,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: focused
              ? Theme.of(context).colorScheme.primary
              : AppColors.border,
          width: focused ? 1.5 : 1,
        ),
      ),
      child: Focus(
        onFocusChange: (value) {
          setState(() {
            focused = value;
          });
        },
        child: TextField(
          controller: widget.controller,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon:
                widget.prefixIcon ??
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
            suffixIcon: widget.suffixIcon,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
