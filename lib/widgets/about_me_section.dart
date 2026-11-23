import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/size.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/widgets/about_me.dart';

class AboutMeSection extends StatelessWidget {
  const AboutMeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= kMedDesktopWidth;
    final isMobile = screenWidth < 600;

    return Container(
      width: screenWidth,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 36 : 48,
        isMobile ? 16 : 24,
        isMobile ? 44 : 64,
      ),
      color: CustomColor.bgLight2.withValues(alpha: 0.55),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StoryChapterHeader(
                chapterNumber: "Chapter I",
                title: "The Origin & Journey",
                subtitle:
                    "From academic distinction in Computer Science to engineering cross-platform production apps.",
              ),
              SizedBox(height: isMobile ? 28 : 40),
              AboutMe(isDesktop: isDesktop),
            ],
          ),
        ),
      ),
    );
  }
}
