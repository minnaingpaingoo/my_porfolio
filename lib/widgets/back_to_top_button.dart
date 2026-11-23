import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';

class BackToTopButton extends StatefulWidget {
  final ScrollController? scrollController;
  final VoidCallback? onPressed;
  final bool? isVisibleOverride;
  final double? progressOverride;
  final String? templateIdOverride;

  const BackToTopButton({
    super.key,
    this.scrollController,
    this.onPressed,
    this.isVisibleOverride,
    this.progressOverride,
    this.templateIdOverride,
  });

  @override
  State<BackToTopButton> createState() => _BackToTopButtonState();
}

class _BackToTopButtonState extends State<BackToTopButton> {
  bool _isVisible = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant BackToTopButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final ctrl = widget.scrollController;
    if (ctrl == null || !ctrl.hasClients) return;
    final offset = ctrl.offset;
    final maxExtent = ctrl.position.maxScrollExtent;
    final shouldShow = offset > 320;
    final newProgress =
        maxExtent > 0 ? (offset / maxExtent).clamp(0.0, 1.0) : 0.0;

    if (shouldShow != _isVisible || (newProgress - _progress).abs() > 0.02) {
      setState(() {
        _isVisible = shouldShow;
        _progress = newProgress;
      });
    }
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }
    final ctrl = widget.scrollController;
    if (ctrl != null && ctrl.hasClients) {
      ctrl.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioRepository.instance;
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final visible = widget.isVisibleOverride ?? _isVisible;
        final progress =
            (widget.progressOverride ?? _progress).clamp(0.0, 1.0);
        final activeTemplate =
            widget.templateIdOverride ?? repo.activeTemplate;

        return AnimatedScale(
          scale: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _buildTemplateSpecificButton(activeTemplate, progress),
          ),
        );
      },
    );
  }

  Widget _buildTemplateSpecificButton(String templateId, double progress) {
    switch (templateId) {
      case 'book_reader':
        return const SizedBox.shrink();
      case 'bento':
        return _buildCyberBentoButton(progress);
      case 'minimal':
        return _buildExecutiveSplitScreenButton(progress);
      case 'storybook':
      default:
        return _buildMidnightStorybookButton(progress);
    }
  }

  /// 1. Midnight Storybook: Royal Gold Medallion with Circular Reading Ring
  Widget _buildMidnightStorybookButton(double progress) {
    return Tooltip(
      message: "Return to Prologue (${(progress * 100).round()}% read)",
      child: SizedBox(
        width: 54,
        height: 54,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: CustomColor.cardBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  CustomColor.yellowSecondary,
                ),
              ),
            ),
            FloatingActionButton.small(
              heroTag: 'storybook_back_to_top',
              onPressed: _handleTap,
              backgroundColor: CustomColor.yellowPrimary,
              foregroundColor: CustomColor.scaffoldBg,
              elevation: 6,
              child: const Icon(Icons.auto_stories_rounded, size: 19),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. Cyber Bento Grid: Futuristic Neon Cyan/Violet Bento Tile with % Readout
  Widget _buildCyberBentoButton(double progress) {
    const cyan = Color(0xff22D3EE);
    const violet = Color(0xffA855F7);
    const surface = Color(0xff101624);
    final pct = (progress * 100).round();

    return Tooltip(
      message: "Warp to Bento Top [$pct%]",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cyan, width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: cyan.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [cyan, violet],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.keyboard_double_arrow_up_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                Text(
                  "$pct%",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: cyan,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 3. Executive Split-Screen: Clean White Architectural Pill with Cobalt Bar
  Widget _buildExecutiveSplitScreenButton(double progress) {
    const cobalt = Color(0xff2563EB);
    const inkPrimary = Color(0xff0F172A);
    const borderSlate = Color(0xffE2E8F0);

    return Tooltip(
      message: "Back to Top (${(progress * 100).round()}%)",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 54,
            height: 54,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderSlate, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: inkPrimary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.north_rounded,
                        color: cobalt,
                        size: 18,
                      ),
                      SizedBox(height: 1),
                      Text(
                        "TOP",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: inkPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 3.5,
                  backgroundColor: const Color(0xffF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(cobalt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
