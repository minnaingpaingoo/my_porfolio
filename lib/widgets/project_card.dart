import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/utils/project_utils.dart';
import 'package:my_porfolio/widgets/portfolio_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectCardWidget extends StatefulWidget {
  const ProjectCardWidget({
    super.key,
    required this.project,
    this.storyIndex,
    this.cardWidth = 330,
  });

  final ProjectUtils project;
  final int? storyIndex;
  final double cardWidth;

  @override
  State<ProjectCardWidget> createState() => _ProjectCardWidgetState();
}

class _ProjectCardWidgetState extends State<ProjectCardWidget> {
  bool _isHovered = false;

  Future<void> _openUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showProjectStoryModal(BuildContext context) {
    final project = widget.project;
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = (screenHeight * 0.3).clamp(135.0, 230.0);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: CustomColor.bgLight1,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: CustomColor.cardBorder, width: 1.2),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Banner Artwork
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: PortfolioImage(
                          imagePath: project.image,
                          height: bannerHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                CustomColor.scaffoldBg.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: CustomColor.yellowPrimary
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            project.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: CustomColor.yellowSecondary,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                CustomColor.scaffoldBg.withValues(alpha: 0.85),
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                        if (project.techStack.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final tech in project.techStack)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CustomColor.yellowPrimary
                                        .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: CustomColor.yellowPrimary
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    tech,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: CustomColor.yellowSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 18),
                        const Text(
                          "CHRONICLE OVERVIEW",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: CustomColor.hintDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.detail,
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: CustomColor.whiteSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Divider(color: CustomColor.cardBorder),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.end,
                          children: [
                            if (project.githubLink != null)
                              ElevatedButton.icon(
                                onPressed: () => _openUrl(project.githubLink),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColor.bgLight2,
                                  foregroundColor: CustomColor.whitePrimary,
                                  side: const BorderSide(
                                    color: CustomColor.cardBorder,
                                  ),
                                ),
                                icon: const Icon(Icons.code_rounded, size: 17),
                                label: const Text("View on GitHub"),
                              ),
                            if (project.webLink != null)
                              ElevatedButton.icon(
                                onPressed: () => _openUrl(project.webLink),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColor.yellowPrimary,
                                  foregroundColor: CustomColor.scaffoldBg,
                                ),
                                icon: const Icon(
                                  Icons.language_rounded,
                                  size: 17,
                                ),
                                label: const Text(
                                  "Visit Live Website",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            if (project.androidLink != null)
                              ElevatedButton.icon(
                                onPressed: () => _openUrl(project.androidLink),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColor.bgLight2,
                                  foregroundColor: CustomColor.whitePrimary,
                                ),
                                icon:
                                    const Icon(Icons.android_rounded, size: 17),
                                label: const Text("Android App"),
                              ),
                            if (project.iosLink != null)
                              ElevatedButton.icon(
                                onPressed: () => _openUrl(project.iosLink),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColor.bgLight2,
                                  foregroundColor: CustomColor.whitePrimary,
                                ),
                                icon: const Icon(Icons.apple_rounded, size: 17),
                                label: const Text("iOS App"),
                              ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text(
                                "Close Story",
                                style: TextStyle(
                                  color: CustomColor.yellowSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final chapterNo = widget.storyIndex != null
        ? "No. ${widget.storyIndex!.toString().padLeft(2, '0')}"
        : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _showProjectStoryModal(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
          clipBehavior: Clip.antiAlias,
          width: widget.cardWidth,
          height: 410,
          decoration: kStoryCardDecoration(
            isHighlighted: _isHovered,
            backgroundColor: CustomColor.bgLight2,
            borderRadius: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image with Story Number & Category Pill
              Stack(
                children: [
                  PortfolioImage(
                    imagePath: project.image,
                    height: 165,
                    width: widget.cardWidth,
                    fit: BoxFit.cover,
                  ),
                  if (chapterNo != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CustomColor.scaffoldBg.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: CustomColor.yellowPrimary
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          chapterNo,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: CustomColor.yellowSecondary,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CustomColor.scaffoldBg.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        project.category,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: CustomColor.whitePrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Title & Subtitle
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: CustomColor.whitePrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  project.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CustomColor.whiteSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              // Tech Stack Badges
              if (project.techStack.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final tech in project.techStack.take(4))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: CustomColor.bgLight1,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: CustomColor.cardBorder),
                          ),
                          child: Text(
                            tech,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: CustomColor.yellowSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              // Footer Bar
              Container(
                color: CustomColor.bgLight1,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Text(
                      "Links:",
                      style: TextStyle(
                        color: CustomColor.hintDark,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (project.androidLink != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => _openUrl(project.androidLink),
                          child: Image.asset(
                            "assets/android_icon.png",
                            width: 18,
                          ),
                        ),
                      ),
                    if (project.iosLink != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => _openUrl(project.iosLink),
                          child: Image.asset(
                            "assets/ios.png",
                            width: 18,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                      ),
                    if (project.webLink != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => _openUrl(project.webLink),
                          child: Image.asset(
                            "assets/web.png",
                            width: 18,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                      ),
                    if (project.githubLink != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => _openUrl(project.githubLink),
                          child: Image.asset(
                            "assets/github.png",
                            width: 18,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showProjectStoryModal(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(
                        Icons.menu_book_rounded,
                        size: 14,
                        color: CustomColor.yellowSecondary,
                      ),
                      label: const Text(
                        "Read Details",
                        style: TextStyle(
                          color: CustomColor.yellowSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
