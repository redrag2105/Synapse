import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/utils/app_formatters.dart';

import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/usecases/publication/search_publications_usecase.dart';
import 'package:synapse/presentation/controllers/top_author_controller.dart';
import 'package:synapse/presentation/controllers/top_journal_controller.dart';

final dashboardPublicationsProvider = FutureProvider.autoDispose
    .family<List<PublicationEntity>, String>((ref, keyword) async {
      final useCase = ref.read(searchPublicationsUseCaseProvider);
      final result = await useCase(SearchPublicationsParams(keyword: keyword));
      return result.fold(
        (failure) => throw failure,
        (publications) => publications,
      );
    });

class ResearchDashboardScreen extends ConsumerStatefulWidget {
  final String keyword;
  const ResearchDashboardScreen({super.key, required this.keyword});

  @override
  ConsumerState<ResearchDashboardScreen> createState() =>
      _ResearchDashboardScreenState();
}

class _ResearchDashboardScreenState
    extends ConsumerState<ResearchDashboardScreen> {
  late final String _actualKeyword;

  @override
  void initState() {
    super.initState();
    _actualKeyword = widget.keyword == '__ALL__' ? '' : widget.keyword;
    _fetchData();
  }

  @override
  void didUpdateWidget(ResearchDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyword != widget.keyword) {
      _actualKeyword = widget.keyword == '__ALL__' ? '' : widget.keyword;
      _fetchData();
    }
  }

  void _fetchData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(topAuthorsControllerProvider.notifier)
          .fetchTopAuthors(_actualKeyword, limit: 1);
      ref
          .read(topJournalsControllerProvider.notifier)
          .fetchTopJournals(_actualKeyword, limit: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardPubsState = ref.watch(
      dashboardPublicationsProvider(_actualKeyword),
    );
    final authorState = ref.watch(topAuthorsControllerProvider);
    final journalState = ref.watch(topJournalsControllerProvider);

    final bool isLoading =
        dashboardPubsState.isLoading ||
        authorState.isLoading ||
        journalState.isLoading;

    final String displayTitle = widget.keyword == '__ALL__'
        ? 'GLOBAL'
        : widget.keyword;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${displayTitle.toUpperCase()} ANALYTICS',
          style: AppTextStyles.metadata.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderGray, height: 0.5),
        ),
      ),
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : dashboardPubsState.when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Error rendering intelligence: $err')),
              data: (publications) {
                if (publications.isEmpty) {
                  return const Center(
                    child: Text('No data found to aggregate dashboard.'),
                  );
                }

                // 1. Tính toán các chỉ số Tổng quan
                final totalPapers = publications.length;
                final totalCitations = publications.fold<int>(
                  0,
                  (sum, p) => sum + p.citationCount,
                );
                final avgCitations = totalPapers > 0
                    ? (totalCitations / totalPapers).toStringAsFixed(1)
                    : '0';

                // Bài báo có ảnh hưởng nhất (Do danh sách đã được sắp xếp theo số trích dẫn từ trước)
                final primaryPaper = publications.first;

                // 2. Lấy Tác giả và Tạp chí Top 1 từ State
                final topAuthor = authorState.value?.authors.items.isNotEmpty ==
                        true
                    ? authorState.value!.authors.items.first
                    : null;
                final topJournal = journalState.value?.isNotEmpty == true
                    ? journalState.value!.first
                    : null;

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // PHẦN THỐNG KÊ TỔNG QUAN (Vibe Springer Nature: Tối giản, tập trung vào Typography)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildEditorialMetricCard(
                            label: 'TOTAL VOLUME',
                            value: AppFormatters.formatNumber(totalPapers),
                            unit: 'scholarly works',
                          ),
                        ),
                        Container(
                          width: 0.5,
                          height: 70,
                          color: AppColors.borderGray,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildEditorialMetricCard(
                            label: 'AVG CITATION IMPACT',
                            value: avgCitations,
                            unit: 'citations per paper',
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(
                        height: 0.5,
                        color: AppColors.borderGray,
                        thickness: 0.5,
                      ),
                    ),

                    // PHẦN CHI TIẾT THỰC THỂ DẪN ĐẦU (LEADERSHIP DISCOVERY)
                    Text(
                      'RESEARCH LEADERSHIP',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 12,
                        color: AppColors.textLight,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildIntelligenceRow(
                      icon: CupertinoIcons.person_fill,
                      title: 'Pioneering Researcher',
                      name: topAuthor?.displayName ?? 'Analyzing...',
                      meta: topAuthor != null
                          ? '${AppFormatters.formatNumber(topAuthor.worksCount)} related papers'
                          : '',
                    ),
                    const SizedBox(height: 20),
                    _buildIntelligenceRow(
                      icon: CupertinoIcons.book_fill,
                      title: 'Primary Publishing Source',
                      name: topJournal?.displayName ?? 'Analyzing...',
                      meta: topJournal != null
                          ? 'Highest publication frequency'
                          : '',
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(
                        height: 0.5,
                        color: AppColors.borderGray,
                        thickness: 0.5,
                      ),
                    ),

                    // PHẦN BÀI BÁO CÓ ẢNH HƯỞNG NHẤT (MOST INFLUENTIAL WORK)
                    Text(
                      'MOST INFLUENTIAL WORK',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 12,
                        color: AppColors.textLight,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            primaryPaper.title,
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 16,
                              color: AppColors.brandBlue900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Published in ${primaryPaper.journalName} (${primaryPaper.publicationYear})',
                            style: AppTextStyles.metadata,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.doc_text,
                                size: 14,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${AppFormatters.formatNumber(primaryPaper.citationCount)} Citations globally',
                                style: AppTextStyles.metadata.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  // Widget hiển thị metric tối giản tinh tế theo phong cách báo in khoa học
  Widget _buildEditorialMetricCard({
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.metadata.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.h1.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: AppColors.brandBlue900,
            fontFamily: 'Merriweather',
          ),
        ),
        Text(
          unit,
          style: AppTextStyles.metadata.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // Hàng thông tin thực thể dẫn đầu tinh gọn
  Widget _buildIntelligenceRow({
    required IconData icon,
    required String title,
    required String name,
    required String meta,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.brandBlue900.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppColors.brandBlue900, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.metadata.copyWith(
                  color: AppColors.textLight,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: AppTextStyles.h3.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontFamily: 'Merriweather',
                ),
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: AppTextStyles.metadata.copyWith(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
