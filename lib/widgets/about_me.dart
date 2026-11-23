import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/models/portfolio_models.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';

class AboutMe extends StatelessWidget {
  final bool isDesktop;

  const AboutMe({
    super.key,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioRepository.instance;
    final experiences = repo.experiences;
    final educations = repo.educations;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: _buildExperienceTimeline(experiences),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 5,
            child: _buildEducationChronicle(educations),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExperienceTimeline(experiences),
        const SizedBox(height: 32),
        _buildEducationChronicle(educations),
      ],
    );
  }

  Widget _buildExperienceTimeline(List<ExperienceItem> experiences) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: kStoryCardDecoration(
        backgroundColor: CustomColor.bgLight1,
        borderRadius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CustomColor.yellowPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work_history_rounded,
                  color: CustomColor.yellowSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ACT I · PROFESSIONAL TIMELINE",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: CustomColor.yellowSecondary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Work Experiences",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: CustomColor.whitePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (experiences.isEmpty)
            const Text(
              "No work experiences added yet.",
              style: TextStyle(color: CustomColor.whiteSecondary),
            ),
          for (int i = 0; i < experiences.length; i++)
            _TimelineMilestoneCard(
              item: experiences[i],
              index: i + 1,
              isLast: i == experiences.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildEducationChronicle(List<EducationItem> educations) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: kStoryCardDecoration(
        backgroundColor: CustomColor.bgLight1,
        borderRadius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CustomColor.yellowPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: CustomColor.yellowSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ACT II · ACADEMIC FOUNDATION",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: CustomColor.yellowSecondary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Education & Honors",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: CustomColor.whitePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (educations.isEmpty)
            const Text(
              "No education entries added yet.",
              style: TextStyle(color: CustomColor.whiteSecondary),
            ),
          for (final edu in educations)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: kStoryCardDecoration(
                isHighlighted: true,
                backgroundColor: CustomColor.bgLight2,
                borderRadius: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: CustomColor.yellowPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      edu.period,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CustomColor.yellowSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    edu.degree,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: CustomColor.whitePrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_rounded,
                        size: 15,
                        color: CustomColor.yellowSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          edu.institution,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: CustomColor.whiteSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (edu.honors.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CustomColor.emeraldAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CustomColor.emeraldAccent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: CustomColor.emeraldAccent,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              edu.honors,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: CustomColor.emeraldAccent,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (edu.coursework.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      "KEY COURSEWORK & DOMAINS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: CustomColor.hintDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final course in edu.coursework)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: CustomColor.scaffoldBg.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: CustomColor.cardBorder),
                            ),
                            child: Text(
                              course,
                              style: const TextStyle(
                                fontSize: 12,
                                color: CustomColor.whiteSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineMilestoneCard extends StatelessWidget {
  final ExperienceItem item;
  final int index;
  final bool isLast;

  const _TimelineMilestoneCard({
    required this.item,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline node & vertical connector
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: item.isCurrent
                      ? CustomColor.yellowPrimary
                      : CustomColor.bgLight2,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CustomColor.yellowSecondary,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$index",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: item.isCurrent
                        ? CustomColor.scaffoldBg
                        : CustomColor.yellowSecondary,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: CustomColor.cardBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Milestone Story Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 18),
              padding: const EdgeInsets.all(18),
              decoration: kStoryCardDecoration(
                isHighlighted: item.isCurrent,
                backgroundColor: CustomColor.bgLight2,
                borderRadius: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        item.period,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: CustomColor.yellowSecondary,
                        ),
                      ),
                      if (item.isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: CustomColor.emeraldAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: CustomColor.emeraldAccent.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Text(
                            "CURRENT CHAPTER",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: CustomColor.emeraldAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.role,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: CustomColor.whitePrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.company,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CustomColor.whiteSecondary,
                    ),
                  ),
                  if (item.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: CustomColor.whiteSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (item.highlights.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    for (final bullet in item.highlights)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 5, right: 8),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 12,
                                color: CustomColor.yellowSecondary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                bullet,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: CustomColor.whiteSecondary,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
