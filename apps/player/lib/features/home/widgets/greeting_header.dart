import 'package:flutter/material.dart';

import '../../../app/theme/app_text_styles.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Evening',
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back!',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}