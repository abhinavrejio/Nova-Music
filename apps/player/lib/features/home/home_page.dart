import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/personalization/home_personalization_provider.dart';
import 'builders/home_section_builder.dart';
import 'widgets/greeting_header.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(homePersonalizationProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(36, 32, 36, 0),
            sliver: SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: const GreetingHeader(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(36, 0, 36, 48),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final section = sections[index];

                if (!section.visible) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: HomeSectionBuilder.build(section),
                    ),
                  ),
                );
              }, childCount: sections.length),
            ),
          ),
        ],
      ),
    );
  }
}
