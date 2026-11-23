import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/widgets/portfolio_image.dart';

class MainMobile extends StatelessWidget {
  final VoidCallback onGetInTouch;
  final VoidCallback? onExploreProjects;

  const MainMobile({
    super.key,
    required this.onGetInTouch,
    this.onExploreProjects,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isLandscape = screenWidth > screenHeight;
    final profile = PortfolioRepository.instance.profile;
    final portraitSize = isLandscape
        ? (screenHeight * 0.38).clamp(110.0, 160.0)
        : (screenWidth * 0.44).clamp(140.0, 210.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 360 ? 16 : 22,
        vertical: isLandscape ? 18 : 26,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CustomColor.bgLight1,
            CustomColor.bgLight2,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CustomColor.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: CustomColor.yellowPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: CustomColor.yellowPrimary.withValues(alpha: 0.45),
              ),
            ),
            child: const Text(
              "PROLOGUE · THE DEVELOPER",
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: CustomColor.yellowSecondary,
              ),
            ),
          ),
          SizedBox(height: isLandscape ? 14 : 20),
          // Framed Portrait
          Container(
            width: portraitSize,
            height: portraitSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: CustomColor.yellowSecondary,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: CustomColor.yellowPrimary.withValues(alpha: 0.22),
                  blurRadius: 20,
                ),
              ],
            ),
            child: ClipOval(
              child: PortfolioImage(
                imagePath: profile.avatarImage,
                width: portraitSize,
                height: portraitSize,
                fit: BoxFit.cover,
                fallbackIcon: Icons.person_rounded,
              ),
            ),
          ),
          SizedBox(height: isLandscape ? 14 : 18),
          if (profile.isAvailable &&
              profile.availabilityText.trim().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: CustomColor.emeraldAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: CustomColor.emeraldAccent.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                "● ${profile.availabilityText}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: CustomColor.emeraldAccent,
                ),
              ),
            ),
          Text(
            profile.greeting,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: CustomColor.yellowSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth < 360 ? 25 : 29,
              fontWeight: FontWeight.w900,
              color: CustomColor.whitePrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profile.roleTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17.5,
              fontWeight: FontWeight.w700,
              color: CustomColor.yellowPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.bio,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: CustomColor.whiteSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          if (profile.stats.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: kStoryCardDecoration(
                backgroundColor:
                    CustomColor.scaffoldBg.withValues(alpha: 0.55),
                borderRadius: 14,
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 16,
                runSpacing: 10,
                children: [
                  for (final stat in profile.stats)
                    Column(
                      children: [
                        Text(
                          stat.value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: CustomColor.yellowSecondary,
                          ),
                        ),
                        Text(
                          stat.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: CustomColor.whiteSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          LayoutBuilder(
            builder: (context, btnConstraints) {
              final stackButtons = btnConstraints.maxWidth < 360;
              if (stackButtons) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onExploreProjects ?? onGetInTouch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.yellowPrimary,
                        foregroundColor: CustomColor.scaffoldBg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.auto_stories_rounded, size: 17),
                      label: const Text(
                        "Read Chronicles",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: onGetInTouch,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomColor.whitePrimary,
                        side: const BorderSide(color: CustomColor.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.send_rounded,
                        size: 16,
                        color: CustomColor.yellowSecondary,
                      ),
                      label: const Text(
                        "Get In Touch",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onExploreProjects ?? onGetInTouch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.yellowPrimary,
                        foregroundColor: CustomColor.scaffoldBg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.auto_stories_rounded, size: 17),
                      label: const Text(
                        "Read Chronicles",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onGetInTouch,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomColor.whitePrimary,
                        side: const BorderSide(color: CustomColor.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.send_rounded,
                        size: 16,
                        color: CustomColor.yellowSecondary,
                      ),
                      label: const Text(
                        "Get In Touch",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
