import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/presentation/screens/home/widgets/header_delegate.dart';
import 'package:synapse/presentation/screens/home/widgets/square_feature_card.dart';
import 'package:synapse/presentation/screens/home/widgets/topic_chip.dart';
import 'package:synapse/presentation/screens/home/widgets/wide_feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // HEADER
          SliverPersistentHeader(
            pinned: true,
            delegate: HeaderDelegate(topPadding: topPadding),
          ),

          // MODULES
          SliverPadding(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const WideFeatureCard(
                  title: 'Topic Search & Discovery',
                  subtitle: 'Explore 250M+ scholarly works across disciplines.',
                  icon: CupertinoIcons.search,
                  route: AppRoutes.search,
                ),
                const SizedBox(height: 12),

                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(
                        child: SquareFeatureCard(
                          title: 'Trend\nAnalysis',
                          subtitle: 'Track growth',
                          icon: CupertinoIcons.graph_square,
                          route: AppRoutes.trend,
                          isInverted: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: SquareFeatureCard(
                          title: 'Leading\nJournals',
                          subtitle: 'Top sources',
                          icon: CupertinoIcons.book,
                          route: AppRoutes.topJournals,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                const WideFeatureCard(
                  title: 'Top Authors & Researchers',
                  subtitle:
                      'Identify influential pioneers driving the conversation.',
                  icon: CupertinoIcons.person_3,
                  route: AppRoutes.topAuthors,
                ),
              ]),
            ),
          ),

          // SUGGESTED TOPICS
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: 32,
                left: 20,
                right: 20,
                bottom: bottomPadding + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trending Research Topics',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: [
                      TopicChip(label: 'Artificial Intelligence'),
                      TopicChip(label: 'Software Engineering'),
                      TopicChip(label: 'Data Science'),
                      TopicChip(label: 'Cybersecurity'),
                      TopicChip(label: 'Internet of Things'),
                      TopicChip(label: 'Blockchain'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
