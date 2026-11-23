import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/size.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/templates/bento_template_view.dart';
import 'package:my_porfolio/templates/book_reader_template_view.dart';
import 'package:my_porfolio/templates/minimal_template_view.dart';
import 'package:my_porfolio/widgets/about_me_section.dart';
import 'package:my_porfolio/widgets/back_to_top_button.dart';
import 'package:my_porfolio/widgets/contact_section.dart';
import 'package:my_porfolio/widgets/drawer_mobile.dart';
import 'package:my_porfolio/widgets/footer.dart';
import 'package:my_porfolio/widgets/header_desktop.dart';
import 'package:my_porfolio/widgets/header_mobile.dart';
import 'package:my_porfolio/widgets/main_desktop.dart';
import 'package:my_porfolio/widgets/main_mobile.dart';
import 'package:my_porfolio/widgets/project_section.dart';
import 'package:my_porfolio/widgets/skills_desktop.dart';
import 'package:my_porfolio/widgets/skills_mobile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final scrollController = ScrollController();
  final List<GlobalKey> navbarKeys = List.generate(5, (index) => GlobalKey());
  int _activeChapterIndex = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_updateActiveChapterOnScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_updateActiveChapterOnScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _updateActiveChapterOnScroll() {
    if (!scrollController.hasClients) return;
    int detectedIndex = 0;
    for (int i = 0; i < navbarKeys.length; i++) {
      final ctx = navbarKeys[i].currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final pos = box.localToGlobal(Offset.zero).dy;
          if (pos <= 220) {
            detectedIndex = i;
          }
        }
      }
    }
    if (detectedIndex != _activeChapterIndex) {
      setState(() {
        _activeChapterIndex = detectedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final repo = PortfolioRepository.instance;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final activeTemplate = repo.activeTemplate;
        if (activeTemplate == 'book_reader') {
          return BookReaderTemplateView(
            key: ValueKey(repo.profile.footerText),
          );
        }
        if (activeTemplate == 'bento') {
          return BentoTemplateView(key: ValueKey(repo.profile.footerText));
        }
        if (activeTemplate == 'minimal') {
          return MinimalTemplateView(key: ValueKey(repo.profile.footerText));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Use desktop header on wide viewports that aren't ultra-short mobile landscape
            final isDesktopHeader =
                constraints.maxWidth >= 760 && screenHeight >= 420;
            final isHeroSideBySide = constraints.maxWidth >= kMinDesktopWidth;
            final isMobilePadding = constraints.maxWidth < 600;

            return Scaffold(
              key: scaffoldKey,
              backgroundColor: CustomColor.scaffoldBg,
              floatingActionButton: BackToTopButton(
                scrollController: scrollController,
              ),
              endDrawer: isDesktopHeader
                  ? null
                  : DrawerMobile(
                      activeNavIndex: _activeChapterIndex,
                      onNavItemTap: (int navIndex) {
                        scaffoldKey.currentState?.closeEndDrawer();
                        scrollToSection(navIndex);
                      },
                    ),
              body: SafeArea(
                child: Column(
                  children: [
                    // Sticky Storybook Chapter Header
                    if (isDesktopHeader)
                      HeaderDesktop(
                        activeNavIndex: _activeChapterIndex,
                        onNavMenuTap: (int navIndex) {
                          scrollToSection(navIndex);
                        },
                      )
                    else
                      HeaderMobile(
                        onLogoTap: () => scrollToSection(0),
                        onMenuTap: () {
                          scaffoldKey.currentState?.openEndDrawer();
                        },
                      ),

                    // Scrollable Storybook Spreads
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            SizedBox(key: navbarKeys[0]),
                            // PROLOGUE: Developer Cover & Hero Spread
                            if (isHeroSideBySide)
                              MainDesktop(
                                onGetInTouch: () => scrollToSection(4),
                                onExploreProjects: () => scrollToSection(3),
                              )
                            else
                              MainMobile(
                                onGetInTouch: () => scrollToSection(4),
                                onExploreProjects: () => scrollToSection(3),
                              ),

                            // CHAPTER I: The Origin & Journey (About Me Timeline & Education)
                            AboutMeSection(key: navbarKeys[1]),

                            // CHAPTER II: The Craftsman's Arsenal (Platforms & Categorized Skills)
                            Container(
                              key: navbarKeys[2],
                              width: screenWidth,
                              padding: EdgeInsets.fromLTRB(
                                isMobilePadding ? 16 : 24,
                                isMobilePadding ? 36 : 48,
                                isMobilePadding ? 16 : 24,
                                isMobilePadding ? 44 : 64,
                              ),
                              color: CustomColor.bgLight1,
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: kMaxContentWidth,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const StoryChapterHeader(
                                        chapterNumber: "Chapter II",
                                        title: "What I Can Do",
                                        subtitle:
                                            "The Craftsman's Arsenal — cross-platform realms, languages, frameworks, and engineering tools.",
                                      ),
                                      SizedBox(
                                          height: isMobilePadding ? 28 : 40),
                                      if (constraints.maxWidth >=
                                          kMedDesktopWidth)
                                        SkillsDesktop(
                                          key: ValueKey(
                                            'skills_desktop_${repo.platforms.length}_${repo.skills.length}',
                                          ),
                                        )
                                      else
                                        SkillsMobile(
                                          key: ValueKey(
                                            'skills_mobile_${repo.platforms.length}_${repo.skills.length}',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // CHAPTERS III & IV: Chronicles of Creation (Work & Hobby Projects)
                            ProjectSection(key: navbarKeys[3]),

                            // EPILOGUE: Write the Next Chapter (Contact & Social Bookmarks)
                            ContactSection(key: navbarKeys[4]),

                            // COLOPHON / FOOTER (with 5-tap secret version number)
                            Footer(
                              key: ValueKey(
                                'footer_${repo.profile.footerText}_${repo.profile.fullName}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void scrollToSection(int navIndex) {
    if (navIndex < 0 || navIndex >= navbarKeys.length) return;
    setState(() {
      _activeChapterIndex = navIndex;
    });
    final ctx = navbarKeys[navIndex].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
  }
}
