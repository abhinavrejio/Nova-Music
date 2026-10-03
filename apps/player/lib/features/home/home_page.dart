import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/personalization/home_personalization_provider.dart';
import '../../providers/settings_provider.dart';
import 'builders/home_section_builder.dart';
import 'widgets/greeting_header.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final sections = ref.watch(homePersonalizationProvider);
    final settings = ref.watch(settingsProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,

          // Global Home gradient.
          //
          // ON:
          //     Uses the normal Nova background gradient.
          //
          // OFF:
          //     Uses a completely flat background.
          //
          // AMOLED + OFF:
          //     Theme provides true #000000.
          gradient: settings.gradientBackground
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface,
                    colorScheme.surfaceContainerLowest,
                  ],
                  stops: const [
                    0.0,
                    0.55,
                    1.0,
                  ],
                )
              : null,
        ),

        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [
            // ------------------------------------------------------------
            // HEADER
            // ------------------------------------------------------------

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                36,
                32,
                36,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1400,
                  ),
                  child: const GreetingHeader(),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(
                height: 36,
              ),
            ),

            // ------------------------------------------------------------
            // PERSONALIZED HOME SECTIONS
            // ------------------------------------------------------------

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                36,
                0,
                36,
                48,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final section = sections[index];

                    if (!section.visible) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 40,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1400,
                          ),
                          child: HomeSectionBuilder.build(
                            section,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: sections.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}