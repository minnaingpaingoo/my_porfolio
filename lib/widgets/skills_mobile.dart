import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/skill_items.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/widgets/portfolio_image.dart';

class SkillsMobile extends StatefulWidget {
  const SkillsMobile({super.key});

  @override
  State<SkillsMobile> createState() => _SkillsMobileState();
}

class _SkillsMobileState extends State<SkillsMobile> {
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

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < platforms.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: kStoryCardDecoration(
                backgroundColor: CustomColor.bgLight2,
                borderRadius: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          CustomColor.yellowPrimary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            CustomColor.yellowPrimary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: PortfolioImage(
                      imagePath: platforms[i].img,
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platforms[i].title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                        if (platforms[i].subtitle.trim().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            platforms[i].subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CustomColor.whiteSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in skillCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
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
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (int i = 0; i < filteredSkills.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.bgLight2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CustomColor.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PortfolioImage(
                        imagePath: filteredSkills[i].img,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        filteredSkills[i].title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: CustomColor.whitePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
