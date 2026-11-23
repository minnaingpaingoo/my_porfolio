import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';

class PortfolioTemplateOption {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const PortfolioTemplateOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}

const List<PortfolioTemplateOption> kPortfolioTemplates = [
  PortfolioTemplateOption(
    id: 'book_reader',
    name: 'Interactive Book Reader',
    subtitle: 'Swipe left & right through 3D open-book pages',
    icon: Icons.menu_book_rounded,
    accentColor: Color(0xffF59E0B),
  ),
  PortfolioTemplateOption(
    id: 'storybook',
    name: 'Midnight Storybook',
    subtitle: 'Editorial chapter spreads & gold accents',
    icon: Icons.auto_stories_rounded,
    accentColor: CustomColor.yellowPrimary,
  ),
  PortfolioTemplateOption(
    id: 'bento',
    name: 'Cyber Bento Grid',
    subtitle: 'Modular glassmorphic bento tiles & neon cyan',
    icon: Icons.grid_view_rounded,
    accentColor: Color(0xff22D3EE),
  ),
  PortfolioTemplateOption(
    id: 'minimal',
    name: 'Executive Split-Screen',
    subtitle: 'Clean light magazine layout with sticky sidebar',
    icon: Icons.view_sidebar_rounded,
    accentColor: Color(0xff2563EB),
  ),
];

class TemplateSwitcherButton extends StatelessWidget {
  final bool isLightMode;
  final bool compact;

  const TemplateSwitcherButton({
    super.key,
    this.isLightMode = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioRepository.instance;
    final currentId = repo.activeTemplate;
    final defaultId = repo.defaultTemplate;
    final currentOption = kPortfolioTemplates.firstWhere(
      (t) => t.id == currentId,
      orElse: () => kPortfolioTemplates.first,
    );

    return PopupMenuButton<String>(
      tooltip: "Switch UI/UX Template (Saved on this device only)",
      constraints: const BoxConstraints(minWidth: 270, maxWidth: 330),
      onSelected: (templateId) {
        if (templateId == '__reset_default__') {
          repo.clearVisitorTemplateOverride();
        } else {
          // User panel change: saved only on this device, never sent to Firebase
          repo.setVisitorTemplate(templateId);
        }
      },
      color: isLightMode ? Colors.white : CustomColor.bgLight1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLightMode
              ? const Color(0xffE2E8F0)
              : CustomColor.cardBorder,
        ),
      ),
      offset: const Offset(0, 46),
      itemBuilder: (context) {
        return [
          for (final option in kPortfolioTemplates)
            PopupMenuItem<String>(
              value: option.id,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: option.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      option.icon,
                      size: 18,
                      color: option.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                option.name,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: isLightMode
                                      ? const Color(0xff0F172A)
                                      : CustomColor.whitePrimary,
                                ),
                              ),
                            ),
                            if (option.id == defaultId) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: option.accentColor
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "DEFAULT",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: option.accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          option.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: isLightMode
                                ? const Color(0xff64748B)
                                : CustomColor.whiteSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (option.id == currentId) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 17,
                      color: option.accentColor,
                    ),
                  ],
                ],
              ),
            ),
        ];
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isLightMode
              ? const Color(0xffF1F5F9)
              : currentOption.accentColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: currentOption.accentColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              currentOption.icon,
              size: 15,
              color: currentOption.accentColor,
            ),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                currentOption.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isLightMode
                      ? const Color(0xff0F172A)
                      : CustomColor.whitePrimary,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: currentOption.accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
