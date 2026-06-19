import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/presentation/controllers/publication_detail_controller.dart';
import 'package:synapse/presentation/screens/publication_detail/widgets/publication_banner.dart';
import 'package:synapse/presentation/screens/publication_detail/widgets/publication_content.dart';
import 'package:synapse/presentation/screens/publication_detail/widgets/publication_detail_skeleton.dart';

class PublicationDetailScreen extends ConsumerWidget {
  final String publicationId;

  const PublicationDetailScreen({super.key, required this.publicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(publicationDetailProvider(publicationId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: true,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[...previousChildren, ?currentChild],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: detailState.when(
            loading: () => const PublicationDetailSkeleton(
              key: ValueKey('loading_detail'),
            ),

            error: (error, stack) => Center(
              key: const ValueKey('error_detail'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${error.toString()}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(
                      publicationDetailProvider(publicationId),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),

            data: (publication) {
              final String typeFormatted = AppFormatters.formatArticleType(
                publication.articleType,
              );

              return CustomScrollView(
                key: const ValueKey('data_detail'),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.brandBlue900,
                            AppColors.brandBlue900,
                          ],
                        ),
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    leading: IconButton(
                      icon: const Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text(
                      '${publication.journalName} > $typeFormatted',
                      style: AppTextStyles.metadata.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    titleSpacing: 0,
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        PublicationBanner(publication: publication),
                        PublicationContent(publication: publication),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
