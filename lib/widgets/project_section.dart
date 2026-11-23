import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/size.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/utils/project_utils.dart';
import 'package:my_porfolio/widgets/project_card.dart';

class ProjectSection extends StatefulWidget {
  const ProjectSection({super.key});

  @override
  State<ProjectSection> createState() => _ProjectSectionState();
}

class _ProjectSectionState extends State<ProjectSection> {
  String _selectedCategory = 'All Chronicles';

  static const List<String> _categories = [
    'All Chronicles',
    'Mobile App',
    'Web Platform',
  ];

  List<ProjectUtils> _filter(List<ProjectUtils> list) {
    if (_selectedCategory == 'All Chronicles') return list;
    return list
        .where(
            (p) => p.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  double _calculateCardWidth(double availableWidth) {
    if (availableWidth >= 1040) {
      return ((availableWidth - 48) / 3).clamp(280.0, 350.0);
    } else if (availableWidth >= 600) {
      return ((availableWidth - 24) / 2).clamp(270.0, 360.0);
    }
    return availableWidth.clamp(250.0, 420.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final repo = PortfolioRepository.instance;
    final workList = _filter(repo.workProjects);
    final hobbyList = _filter(repo.hobbyProjects);

    return Container(
      width: screenWidth,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 36 : 48,
        isMobile ? 16 : 24,
        isMobile ? 44 : 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = _calculateCardWidth(constraints.maxWidth);
              return Column(
                children: [
                  // Chapter III: Work Projects
                  StoryChapterHeader(
                    chapterNumber: "Chapter III",
                    title: "Work Projects",
                    subtitle:
                        "Production client platforms, university systems, and commissioned digital solutions.",
                    trailingAction: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final cat in _categories)
                          ChoiceChip(
                            label: Text(cat),
                            selected: _selectedCategory == cat,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            selectedColor: CustomColor.yellowPrimary,
                            backgroundColor: CustomColor.bgLight2,
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _selectedCategory == cat
                                  ? CustomColor.scaffoldBg
                                  : CustomColor.whiteSecondary,
                            ),
                            side: BorderSide(
                              color: _selectedCategory == cat
                                  ? CustomColor.yellowPrimary
                                  : CustomColor.cardBorder,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 28 : 40),
                  if (workList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No work projects match the selected filter.",
                        style: TextStyle(color: CustomColor.whiteSecondary),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        for (int i = 0; i < workList.length; i++)
                          ProjectCardWidget(
                            project: workList[i],
                            storyIndex: i + 1,
                            cardWidth: cardWidth,
                          ),
                      ],
                    ),

                  SizedBox(height: isMobile ? 48 : 72),

                  // Chapter IV: Hobby Projects
                  const StoryChapterHeader(
                    chapterNumber: "Chapter IV",
                    title: "Hobby Projects",
                    subtitle:
                        "Side quests, architectural experiments, and personal Flutter mobile creations.",
                  ),
                  SizedBox(height: isMobile ? 28 : 40),
                  if (hobbyList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No hobby projects match the selected filter.",
                        style: TextStyle(color: CustomColor.whiteSecondary),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        for (int i = 0; i < hobbyList.length; i++)
                          ProjectCardWidget(
                            project: hobbyList[i],
                            storyIndex: i + 1,
                            cardWidth: cardWidth,
                          ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
