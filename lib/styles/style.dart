import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';

BoxDecoration kHeaderDecoration = BoxDecoration(
  color: CustomColor.bgLight1.withValues(alpha: 0.92),
  borderRadius: BorderRadius.circular(100),
  border: Border.all(
    color: CustomColor.cardBorder,
    width: 1,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ],
);

BoxDecoration kStoryCardDecoration({
  bool isHighlighted = false,
  Color? backgroundColor,
  double borderRadius = 16,
}) {
  return BoxDecoration(
    color: backgroundColor ?? CustomColor.bgLight2,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: isHighlighted
          ? CustomColor.yellowPrimary.withValues(alpha: 0.75)
          : CustomColor.cardBorder,
      width: isHighlighted ? 1.5 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: isHighlighted
            ? CustomColor.yellowPrimary.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.25),
        blurRadius: isHighlighted ? 24 : 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

class StoryChapterHeader extends StatelessWidget {
  final String chapterNumber;
  final String title;
  final String subtitle;
  final Widget? trailingAction;

  const StoryChapterHeader({
    super.key,
    required this.chapterNumber,
    required this.title,
    required this.subtitle,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: CustomColor.yellowPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: CustomColor.yellowPrimary.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 14,
                color: CustomColor.yellowSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                chapterNumber.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: CustomColor.yellowSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: CustomColor.whitePrimary,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: CustomColor.whiteSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    CustomColor.yellowPrimary.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "✦",
                style: TextStyle(
                  color: CustomColor.yellowPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              width: 50,
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomColor.yellowPrimary.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
        if (trailingAction != null) ...[
          const SizedBox(height: 16),
          trailingAction!,
        ],
      ],
    );
  }
}
