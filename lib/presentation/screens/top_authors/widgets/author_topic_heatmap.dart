import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/domain/entities/author_topic_matrix_entity.dart';

class AuthorTopicHeatmap extends StatelessWidget {
  final AuthorTopicMatrix matrix;

  const AuthorTopicHeatmap({super.key, required this.matrix});

  static final Color _lowColor =
      AppColors.brandBlue900.withValues(alpha: 0.06);
  static const Color _highColor = AppColors.brandBlue700;

  String _lastName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.last;
  }

  Color _cellColor(int count, int maxCount) {
    if (count <= 0 || maxCount <= 0) return _lowColor;
    final t = (count / maxCount).clamp(0.0, 1.0);
    return Color.lerp(_lowColor, _highColor, t)!;
  }

  Color _cellTextColor(int count, int maxCount) {
    if (count <= 0 || maxCount <= 0) return AppColors.textLight;
    final t = (count / maxCount).clamp(0.0, 1.0);
    return t > 0.55 ? Colors.white : AppColors.brandBlue900;
  }

  void _showDetailSheet(
    BuildContext context, {
    required String title,
    required List<({String label, String value})> rows,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    color: AppColors.brandBlue900,
                  ),
                ),
                const SizedBox(height: 16),
                ...rows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.label,
                          style: AppTextStyles.metadata.copyWith(
                            fontSize: 11,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          row.value,
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCellDetail(
    BuildContext context, {
    required String topicName,
    required String authorName,
    required int count,
  }) {
    _showDetailSheet(
      context,
      title: 'Research Correlation',
      rows: [
        (label: 'RESEARCH TOPIC', value: topicName),
        (label: 'AUTHOR', value: authorName),
        (
          label: 'WORKS IN THIS TOPIC',
          value: count > 0 ? '$count publications' : 'No publications',
        ),
      ],
    );
  }

  void _showTopicDetail(BuildContext context, String topicName) {
    _showDetailSheet(
      context,
      title: 'Research Topic',
      rows: [(label: 'FULL NAME', value: topicName)],
    );
  }

  void _showAuthorDetail(BuildContext context, String authorName) {
    _showDetailSheet(
      context,
      title: 'Researcher',
      rows: [(label: 'FULL NAME', value: authorName)],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (matrix.topicNames.isEmpty || matrix.authorNames.isEmpty) {
      return const SizedBox.shrink();
    }

    final flatCounts = matrix.counts.expand((row) => row);
    final maxCount = flatCounts.isEmpty
        ? 0
        : flatCounts.reduce((a, b) => a > b ? a : b);

    final authorCount = matrix.authorNames.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.brandBlue900.withValues(alpha: 0.02),
                  AppColors.brandBlue700.withValues(alpha: 0.12),
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.brandBlue900.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Author-Topic Matrix',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 15,
                    color: AppColors.brandBlue900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Correlation between key researchers and emerging domains',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap a cell or label to view full details',
                  style: AppTextStyles.metadata.copyWith(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const topicLabelWidth = 92.0;
              const cellGap = 4.0;
              final gridWidth = constraints.maxWidth - topicLabelWidth;
              final cellSize = authorCount > 0
                  ? ((gridWidth - cellGap * (authorCount - 1)) / authorCount)
                      .clamp(30.0, 48.0)
                  : 40.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...matrix.topicNames.asMap().entries.map((topicEntry) {
                    final topicIndex = topicEntry.key;
                    final topicName = topicEntry.value;

                    return Padding(
                      padding: EdgeInsets.only(bottom: cellGap),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: topicLabelWidth,
                            height: cellSize,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () =>
                                    _showTopicDetail(context, topicName),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    topicName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.metadata.copyWith(
                                      fontSize: 10,
                                      height: 1.2,
                                      color: AppColors.brandBlue700,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.brandBlue700
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ...matrix.authorNames.asMap().entries.map(
                            (authorEntry) {
                              final authorIndex = authorEntry.key;
                              final authorName =
                                  matrix.authorNames[authorIndex];
                              final count =
                                  matrix.counts[authorIndex][topicIndex];

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: () => _showCellDetail(
                                    context,
                                    topicName: topicName,
                                    authorName: authorName,
                                    count: count,
                                  ),
                                  child: Container(
                                    width: cellSize,
                                    height: cellSize,
                                    margin: EdgeInsets.only(
                                      right: authorIndex < authorCount - 1
                                          ? cellGap
                                          : 0,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _cellColor(count, maxCount),
                                      borderRadius: BorderRadius.circular(6),
                                      border: count > 0
                                          ? Border.all(
                                              color: AppColors.brandBlue900
                                                  .withValues(alpha: 0.08),
                                            )
                                          : null,
                                    ),
                                    child: count > 0
                                        ? Text(
                                            '$count',
                                            style: AppTextStyles.metadata
                                                .copyWith(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _cellTextColor(
                                                count,
                                                maxCount,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: topicLabelWidth),
                      ...matrix.authorNames.asMap().entries.map((entry) {
                        final index = entry.key;
                        final fullName = entry.value;
                        final shortName = _lastName(fullName);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () => _showAuthorDetail(context, fullName),
                            child: Container(
                              width: cellSize,
                              height: 36,
                              margin: EdgeInsets.only(
                                right: index < authorCount - 1 ? cellGap : 0,
                              ),
                              alignment: Alignment.topCenter,
                              child: Text(
                                shortName,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.metadata.copyWith(
                                  fontSize: 9,
                                  height: 1.15,
                                  color: AppColors.brandBlue900,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.brandBlue900
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Low',
                style: AppTextStyles.metadata.copyWith(
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [_lowColor, _highColor],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'High',
                style: AppTextStyles.metadata.copyWith(
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
