import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/greeting_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/continue_listening_section.dart';
import 'widgets/collections_section.dart';
import 'widgets/recently_played_section.dart';
import 'widgets/album_section.dart';
import 'widgets/artists_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 1180,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  GreetingHeader(),

                  SizedBox(height: 32),

                  HomeSearchBar(),

                  SizedBox(height: 40),

                  ContinueListeningSection(),

                  SizedBox(height: 48),

                  CollectionsSection(),

                  SizedBox(height: 48),

                  RecentlyPlayedSection(),

                  SizedBox(height: 48),

                  AlbumsSection(),

                  SizedBox(height: 48),

                  ArtistsSection(),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}