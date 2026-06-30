import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

/// Expandable Research Insights FAB with full-screen dim overlay (shell tab bar stays above).
class ResearchInsightsFab extends StatefulWidget {
  final double tabBarInset;
  final String keyword;
  final bool screenActive;
  final VoidCallback onTrend;
  final VoidCallback onAuthors;
  final VoidCallback onJournals;

  const ResearchInsightsFab({
    super.key,
    required this.tabBarInset,
    required this.keyword,
    this.screenActive = true,
    required this.onTrend,
    required this.onAuthors,
    required this.onJournals,
  });

  @override
  State<ResearchInsightsFab> createState() => _ResearchInsightsFabState();
}

class _ResearchInsightsFabState extends State<ResearchInsightsFab>
    with SingleTickerProviderStateMixin {
  static const double _fabSize = 56;
  static const double _itemSpacing = 14;

  late final AnimationController _controller;
  late final Animation<double> _expand;

  bool get _isOpen => _controller.value > 0.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expand = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ResearchInsightsFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screenActive && !widget.screenActive) {
      _dismiss();
    }
  }

  void _dismiss() {
    _controller.stop();
    if (_controller.value > 0) {
      _controller.value = 0;
    }
  }

  void _open() => _controller.forward();

  void _close() => _controller.reverse();

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  Future<void> _closeThen(VoidCallback action) async {
    if (_controller.value > 0) {
      await _controller.reverse();
    }
    if (mounted) action();
  }

  double _staggeredProgress(int index) {
    const stagger = 0.14;
    final start = index * stagger;
    if (_expand.value <= start) return 0;
    final raw = ((_expand.value - start) / (1 - start)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(raw);
  }

  @override
  Widget build(BuildContext context) {
    final bottomOffset = widget.tabBarInset + 16;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _expand,
          builder: (context, _) {
            final t = _expand.value.clamp(0.0, 1.0);
            if (t == 0 && !_controller.isAnimating) {
              return const SizedBox.shrink();
            }

            return Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45 * t),
                ),
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: bottomOffset,
          child: AnimatedBuilder(
            animation: _expand,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _InsightMenuItem(
                    progress: _staggeredProgress(2),
                    label: 'Journals',
                    icon: CupertinoIcons.book_fill,
                    accentColor: AppColors.brandBlue500,
                    onTap: () => _closeThen(widget.onJournals),
                  ),
                  SizedBox(height: _itemSpacing * _staggeredProgress(2)),
                  _InsightMenuItem(
                    progress: _staggeredProgress(1),
                    label: 'Authors',
                    icon: CupertinoIcons.person_2_fill,
                    accentColor: AppColors.brandBlue600,
                    onTap: () => _closeThen(widget.onAuthors),
                  ),
                  SizedBox(height: _itemSpacing * _staggeredProgress(1)),
                  _InsightMenuItem(
                    progress: _staggeredProgress(0),
                    label: 'Trend',
                    icon: CupertinoIcons.chart_bar_alt_fill,
                    accentColor: AppColors.brandBlue700,
                    onTap: () => _closeThen(widget.onTrend),
                  ),
                  const SizedBox(height: 16),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5).animate(_expand),
                    child: SizedBox(
                      width: _fabSize,
                      height: _fabSize,
                      child: FloatingActionButton(
                        onPressed: _toggle,
                        backgroundColor: AppColors.brandGold,
                        foregroundColor: const Color(0xFFE6E6E7),
                        elevation: 6,
                        shape: const CircleBorder(),
                        child: AnimatedSwitcher(
                          switchOutCurve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 70),
                          child: Icon(
                            _isOpen
                                ? CupertinoIcons.xmark
                                : CupertinoIcons.lightbulb_fill,
                            key: ValueKey(_isOpen),
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InsightMenuItem extends StatelessWidget {
  final double progress;
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _InsightMenuItem({
    required this.progress,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = progress.clamp(0.0, 1.0);
    final scale = (0.72 + (0.28 * progress)).clamp(0.0, 1.0);

    if (opacity <= 0) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: opacity < 0.5,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.centerRight,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - progress)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandBlue900.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: accentColor, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.borderGray),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandBlue900.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        label,
                        style: AppTextStyles.button.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandBlue900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
