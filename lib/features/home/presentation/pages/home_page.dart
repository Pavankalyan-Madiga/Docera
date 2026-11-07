import 'package:flutter/material.dart';

import '../widgets/feature_carousel.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_files_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.onSeeAllFiles,
  });

  final VoidCallback? onSeeAllFiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                10,
              ),
              child: HomeAppBar(
                onSettingsTap: () {
                  
                },
              ),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 4),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.only(left: 18),
                    sliver: SliverToBoxAdapter(
                      child: FeatureCarousel(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: QuickActions(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      0,
                      18,
                      100,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: RecentFilesSection(
                        onSeeAll: onSeeAllFiles,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}