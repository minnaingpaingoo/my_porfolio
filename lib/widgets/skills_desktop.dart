import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/skill_items.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/widgets/portfolio_image.dart';

class SkillsDesktop extends StatefulWidget {
  const SkillsDesktop({super.key});

  @override
  State<SkillsDesktop> createState() => _SkillsDesktopState();
}

class _SkillsDesktopState extends State<SkillsDesktop> {
  String _selectedCategory = skillCategories.first;

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioRepository.instance;
    final platforms = repo.platforms;
    final allSkills = repo.skills;
    final filteredSkills = _selectedCategory == "All Tools"
        ? allSkills
        : allSkills
            .where((s) =>
                s.category.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCols = constraints.maxWidth >= 680;
        final cardWidth = twoCols
            ? (constraints.maxWidth - 18) / 2
            : constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Part A: The Four Platform Realms (intrinsic height, responsive 1 or 2 cols)
            const Text(
              "PART I · TARGET REALMS & PLATFORMS",
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: CustomColor.yellowSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                for (final plat in platforms)
                  SizedBox(
                    width: cardWidth,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: kStoryCardDecoration(
                        backgroundColor: CustomColor.bgLight2,
                        borderRadius: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: CustomColor.yellowPrimary
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: CustomColor.yellowPrimary
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: PortfolioImage(
                              imagePath: plat.img,
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                              fallbackIcon: Icons.devices_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  plat.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: CustomColor.whitePrimary,
                                  ),
                                ),
                                if (plat.subtitle.trim().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    plat.subtitle,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: CustomColor.whiteSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 36),

            // Part B: Categorized Technical Arsenal
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  const Text(
                    "PART II · LANGUAGES, FRAMEWORKS & TOOLS",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: CustomColor.yellowSecondary,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in skillCategories)
                        ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: CustomColor.yellowPrimary,
                          backgroundColor: CustomColor.bgLight2,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _selectedCategory == category
                                ? CustomColor.scaffoldBg
                                : CustomColor.whiteSecondary,
                          ),
                          side: BorderSide(
                            color: _selectedCategory == category
                                ? CustomColor.yellowPrimary
                                : CustomColor.cardBorder,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: kStoryCardDecoration(
                backgroundColor:
                    CustomColor.bgLight2.withValues(alpha: 0.8),
                borderRadius: 20,
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final skill in filteredSkills)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: CustomColor.bgLight1,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CustomColor.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PortfolioImage(
                            imagePath: skill.img,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            fallbackIcon: Icons.code_rounded,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                skill.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: CustomColor.whitePrimary,
                                ),
                              ),
                              Text(
                                skill.category,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: CustomColor.yellowSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
