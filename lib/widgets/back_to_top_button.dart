import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';

class BackToTopButton extends StatefulWidget {
  final ScrollController scrollController;

  const BackToTopButton({
    super.key,
    required this.scrollController,
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
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final offset = widget.scrollController.offset;
    final maxExtent = widget.scrollController.position.maxScrollExtent;
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

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Tooltip(
          message: "Return to Prologue (${(_progress * 100).round()}% read)",
          child: SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 3,
                    backgroundColor: CustomColor.cardBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      CustomColor.yellowSecondary,
                    ),
                  ),
                ),
                FloatingActionButton.small(
                  heroTag: 'storybook_back_to_top',
                  onPressed: () {
                    if (widget.scrollController.hasClients) {
                      widget.scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                      );
                    }
                  },
                  backgroundColor: CustomColor.yellowPrimary,
                  foregroundColor: CustomColor.scaffoldBg,
                  elevation: 6,
                  child: const Icon(Icons.arrow_upward_rounded, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
