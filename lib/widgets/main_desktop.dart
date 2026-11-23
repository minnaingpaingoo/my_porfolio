import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/size.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/widgets/portfolio_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDesktop extends StatelessWidget {
  final VoidCallback onGetInTouch;
  final VoidCallback? onExploreProjects;

  const MainDesktop({
    super.key,
    required this.onGetInTouch,
    this.onExploreProjects,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isCompactDesktop = screenWidth < 920 || screenHeight < 500;
    final profile = PortfolioRepository.instance.profile;
    final portraitSize = isCompactDesktop
        ? (screenWidth * 0.22).clamp(160.0, 230.0)
        : (screenWidth * 0.24).clamp(220.0, 330.0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: Container(
          margin: EdgeInsets.fromLTRB(
            isCompactDesktop ? 16 : 24,
            isCompactDesktop ? 10 : 16,
            isCompactDesktop ? 16 : 24,
            isCompactDesktop ? 24 : 36,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isCompactDesktop ? 24 : 44,
            vertical: isCompactDesktop ? 24 : 48,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                CustomColor.bgLight1,
                CustomColor.bgLight2,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: CustomColor.cardBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Page: Developer Introduction & Story Prologue
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                CustomColor.yellowPrimary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: CustomColor.yellowPrimary
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          child: const Text(
                            "PROLOGUE · DEVELOPER'S SPREAD",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                              color: CustomColor.yellowSecondary,
                            ),
                          ),
                        ),
                        if (profile.isAvailable &&
                            profile.availabilityText.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: CustomColor.emeraldAccent
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: CustomColor.emeraldAccent
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: CustomColor.emeraldAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    profile.availabilityText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: CustomColor.emeraldAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isCompactDesktop ? 16 : 24),
                    Text(
                      profile.greeting,
                      style: TextStyle(
                        fontSize: isCompactDesktop ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: CustomColor.yellowSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile.fullName,
                      style: TextStyle(
                        fontSize: isCompactDesktop ? 30 : 44,
                        fontWeight: FontWeight.w900,
                        color: CustomColor.whitePrimary,
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.roleTitle,
                      style: TextStyle(
                        fontSize: isCompactDesktop ? 19 : 24,
                        fontWeight: FontWeight.w700,
                        color: CustomColor.yellowPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile.bio,
                      style: TextStyle(
                        fontSize: isCompactDesktop ? 14 : 15.5,
                        color: CustomColor.whiteSecondary,
                        height: 1.65,
                      ),
                    ),
                    SizedBox(height: isCompactDesktop ? 20 : 28),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: onExploreProjects ?? onGetInTouch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColor.yellowPrimary,
                            foregroundColor: CustomColor.scaffoldBg,
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompactDesktop ? 18 : 24,
                              vertical: isCompactDesktop ? 14 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.auto_stories_rounded, size: 18),
                          label: const Text(
                            "Begin Reading Chronicles",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: onGetInTouch,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CustomColor.whitePrimary,
                            side: const BorderSide(
                              color: CustomColor.cardBorder,
                              width: 1.5,
                            ),
                            backgroundColor:
                                CustomColor.scaffoldBg.withValues(alpha: 0.45),
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompactDesktop ? 16 : 22,
                              vertical: isCompactDesktop ? 14 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(
                            Icons.send_rounded,
                            size: 16,
                            color: CustomColor.yellowSecondary,
                          ),
                          label: const Text(
                            "Get In Touch",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (profile.resumeUrl.trim().isNotEmpty)
                          TextButton.icon(
                            onPressed: () async {
                              final uri = Uri.tryParse(profile.resumeUrl);
                              if (uri != null && await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: CustomColor.yellowSecondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                            icon:
                                const Icon(Icons.open_in_new_rounded, size: 17),
                            label: const Text(
                              "Developer Profile",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    if (profile.stats.isNotEmpty) ...[
                      SizedBox(height: isCompactDesktop ? 22 : 32),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompactDesktop ? 16 : 20,
                          vertical: 14,
                        ),
                        decoration: kStoryCardDecoration(
                          backgroundColor:
                              CustomColor.scaffoldBg.withValues(alpha: 0.55),
                          borderRadius: 14,
                        ),
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 12,
                          children: [
                            for (int i = 0; i < profile.stats.length; i++)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.stats[i].value,
                                    style: TextStyle(
                                      fontSize: isCompactDesktop ? 19 : 22,
                                      fontWeight: FontWeight.w900,
                                      color: CustomColor.yellowSecondary,
                                    ),
                                  ),
                                  Text(
                                    profile.stats[i].label,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: CustomColor.whiteSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: isCompactDesktop ? 20 : 40),
              // Right Page: Framed Developer Portrait Plate
              Expanded(
                flex: 4,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: portraitSize + 24,
                        height: portraitSize + 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CustomColor.yellowPrimary
                                .withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          gradient: RadialGradient(
                            colors: [
                              CustomColor.yellowPrimary.withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: portraitSize,
                        height: portraitSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CustomColor.yellowSecondary,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CustomColor.yellowPrimary
                                  .withValues(alpha: 0.22),
                              blurRadius: 28,
                              spreadRadius: 2,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
