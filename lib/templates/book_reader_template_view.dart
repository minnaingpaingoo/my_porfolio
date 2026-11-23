import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_porfolio/constants/skill_items.dart';
import 'package:my_porfolio/models/portfolio_models.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/utils/project_utils.dart';
import 'package:my_porfolio/widgets/admin_passcode_dialog.dart';
import 'package:my_porfolio/widgets/portfolio_image.dart';
import 'package:my_porfolio/widgets/template_switcher_menu.dart';
import 'package:url_launcher/url_launcher.dart';

/// Custom ScrollBehavior allowing mouse, touch, trackpad, and stylus drag
/// to swipe left and right through book pages on Web, Desktop, and Mobile.
class _BookSwipeScrollBehavior extends MaterialScrollBehavior {
  const _BookSwipeScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class _BookPageData {
  final int pageNumber;
  final String chapterTag;
  final String pageTitle;
  final Widget Function(BuildContext context) builder;

  const _BookPageData({
    required this.pageNumber,
    required this.chapterTag,
    required this.pageTitle,
    required this.builder,
  });
}

/// Template 4: Interactive 3D Page-Flip Book Reader
/// Readers can swipe left/right (touch or mouse drag), use arrow keys,
/// tap page corners, or click chapter bookmark ribbons to flip through pages.
class BookReaderTemplateView extends StatefulWidget {
  const BookReaderTemplateView({super.key});

  @override
  State<BookReaderTemplateView> createState() => _BookReaderTemplateViewState();
}

class _BookReaderTemplateViewState extends State<BookReaderTemplateView> {
  // Reading Desk & Leather Binding Palette
  static const Color _deskBgDark = Color(0xff0F0B08);
  static const Color _deskBgWarm = Color(0xff1C140E);
  static const Color _leatherCover = Color(0xff2E1C10);
  static const Color _leatherBorder = Color(0xff5C3A21);
  static const Color _goldFoil = Color(0xffD4AF37);
  static const Color _goldBright = Color(0xffF59E0B);
  static const Color _crimsonRibbon = Color(0xff991B1B);

  // Parchment vs Night Paper Palette
  bool _isNightPaper = false;

  Color get _paperBg =>
      _isNightPaper ? const Color(0xff181614) : const Color(0xffFBF6EC);
  Color get _paperBgAlt =>
      _isNightPaper ? const Color(0xff221F1B) : const Color(0xffF3EBD9);
  Color get _paperBorder =>
      _isNightPaper ? const Color(0xff38322B) : const Color(0xffDFD1B8);
  Color get _inkTitle =>
      _isNightPaper ? const Color(0xffF8FAFC) : const Color(0xff1E1610);
  Color get _inkBody =>
      _isNightPaper ? const Color(0xffCBD5E1) : const Color(0xff3D3126);
  Color get _inkMuted =>
      _isNightPaper ? const Color(0xff94A3B8) : const Color(0xff786653);
  Color get _accentInk =>
      _isNightPaper ? const Color(0xffF59E0B) : const Color(0xffB45309);

  late final PageController _pageController;
  final FocusNode _keyboardFocusNode = FocusNode();
  int _currentUnitIndex = 0;
  String _selectedSkillCat = skillCategories.first;

  // Contact form state on the Epilogue page
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _keyboardFocusNode.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _goToUnit(int index, int maxUnits) {
    final target = index.clamp(0, math.max(0, maxUnits - 1)).toInt();
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextUnit(int maxUnits) => _goToUnit(_currentUnitIndex + 1, maxUnits);
  void _prevUnit(int maxUnits) => _goToUnit(_currentUnitIndex - 1, maxUnits);

  /// Builds all individual book pages in reading order.
  /// On wide screens, 2 consecutive pages are shown side-by-side as an open
  /// book spread (Left Page + Right Page). On mobile/narrow screens, each page
  /// is shown individually with horizontal swipe.
  List<_BookPageData> _buildBookPages(
    PortfolioRepository repo,
    ProfileData profile,
  ) {
    final workProjects = repo.workProjects;
    final hobbyProjects = repo.hobbyProjects;

    return [
      // PAGE 1: EX LIBRIS & FRONTISPIECE PORTRAIT
      _BookPageData(
        pageNumber: 1,
        chapterTag: "FRONTISPIECE",
        pageTitle: "Ex Libris · The Developer",
        builder: (context) => _buildFrontispiecePage(profile),
      ),
      // PAGE 2: PROLOGUE & NARRATIVE BIO
      _BookPageData(
        pageNumber: 2,
        chapterTag: "PROLOGUE",
        pageTitle: "The Developer's Prologue",
        builder: (context) => _buildProloguePage(profile, repo),
      ),
      // PAGE 3: CHAPTER I (PART A) — PROFESSIONAL WORK TIMELINE
      _BookPageData(
        pageNumber: 3,
        chapterTag: "CHAPTER I · JOURNEY",
        pageTitle: "Professional Chronicles",
        builder: (context) => _buildExperiencePage(repo),
      ),
      // PAGE 4: CHAPTER I (PART B) — ACADEMIC FOUNDATION & SUMMARY
      _BookPageData(
        pageNumber: 4,
        chapterTag: "CHAPTER I · ORIGINS",
        pageTitle: "Academic Foundation & Milestones",
        builder: (context) => _buildEducationPage(repo, profile),
      ),
      // PAGE 5: CHAPTER II (PART A) — TARGET PLATFORMS & REALMS
      _BookPageData(
        pageNumber: 5,
        chapterTag: "CHAPTER II · ARSENAL",
        pageTitle: "Cross-Platform Engineering Realms",
        builder: (context) => _buildPlatformsPage(repo),
      ),
      // PAGE 6: CHAPTER II (PART B) — TECHNICAL SKILLS & TOOLS
      _BookPageData(
        pageNumber: 6,
        chapterTag: "CHAPTER II · ARSENAL",
        pageTitle: "Languages, Frameworks & Tools",
        builder: (context) => _buildSkillsPage(repo),
      ),
      // PAGE 7: CHAPTER III — FEATURED WORK PROJECTS
      _BookPageData(
        pageNumber: 7,
        chapterTag: "CHAPTER III · WORKS",
        pageTitle: "Production Work Chronicles",
        builder: (context) => _buildProjectsPage(
          title: "Featured Work Chronicles",
          subtitle:
              "Production applications engineered for enterprise, telecommunication, and consumer scale.",
          projects: workProjects,
          badgeLabel: "PRODUCTION WORK",
        ),
      ),
      // PAGE 8: CHAPTER IV — HOBBY & EXPERIMENTAL LABS
      _BookPageData(
        pageNumber: 8,
        chapterTag: "CHAPTER IV · LABS",
        pageTitle: "Indie & Experimental Creations",
        builder: (context) => _buildProjectsPage(
          title: "Hobby & Experimental Chronicles",
          subtitle:
              "Explorations in AI, cross-platform utilities, and creative software craftsmanship.",
          projects: hobbyProjects,
          badgeLabel: "INDIE / LAB",
        ),
      ),
      // PAGE 9: EPILOGUE (PART A) — DIRECT CHANNELS & BOOKMARKS
      _BookPageData(
        pageNumber: 9,
        chapterTag: "EPILOGUE · CONNECT",
        pageTitle: "Correspondence & Bookmarks",
        builder: (context) => _buildContactChannelsPage(profile),
      ),
      // PAGE 10: EPILOGUE (PART B) — WRITE THE NEXT CHAPTER & COLOPHON
      _BookPageData(
        pageNumber: 10,
        chapterTag: "COLOPHON",
        pageTitle: "Write the Next Chapter",
        builder: (context) => _buildContactFormAndColophonPage(profile, repo),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioRepository.instance;
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final profile = repo.profile;
        final media = MediaQuery.of(context);
        final screenW = media.size.width;
        final screenH = media.size.height;

        // Show 2-page open book spread on wide screens, 1-page leaf on narrow screens
        final isDualPageSpread = screenW >= 900 && screenH >= 480;
        final allPages = _buildBookPages(repo, profile);
        final totalUnits = isDualPageSpread
            ? (allPages.length / 2).ceil()
            : allPages.length;

        if (_currentUnitIndex >= totalUnits) {
          _currentUnitIndex = math.max(0, totalUnits - 1);
        }

        return Scaffold(
          backgroundColor: _deskBgDark,
          body: SafeArea(
            child: Focus(
              focusNode: _keyboardFocusNode,
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                    _nextUnit(totalUnits);
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    _prevUnit(totalUnits);
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.15,
                    colors: [_deskBgWarm, _deskBgDark],
                  ),
                ),
                child: Column(
                  children: [
                    // 1. TOP READER TOOLBAR & CHAPTER BOOKMARK RIBBONS
                    _buildReaderTopBar(
                      profile: profile,
                      isDualPageSpread: isDualPageSpread,
                      totalUnits: totalUnits,
                      screenW: screenW,
                    ),

                    // 2. INTERACTIVE SWIPEABLE 3D OPEN BOOK
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenW < 600 ? 10 : 28,
                          vertical: screenH < 540 ? 6 : 14,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 1320,
                              maxHeight: 820,
                            ),
                            child: _buildPhysicalBookFrame(
                              allPages: allPages,
                              isDualPageSpread: isDualPageSpread,
                              totalUnits: totalUnits,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. BOTTOM PAGE CONTROLS & SWIPE HINT BAR
                    _buildReaderBottomBar(
                      profile: profile,
                      allPages: allPages,
                      isDualPageSpread: isDualPageSpread,
                      totalUnits: totalUnits,
                      screenW: screenW,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // TOP READER TOOLBAR & CHAPTER BOOKMARK TABS
  // ===========================================================================

  Widget _buildReaderTopBar({
    required ProfileData profile,
    required bool isDualPageSpread,
    required int totalUnits,
    required double screenW,
  }) {
    final isCompact = screenW < 720;
    final bookmarks = [
      (label: "Prologue", pageIndex: 0),
      (label: "I · Journey", pageIndex: 2),
      (label: "II · Arsenal", pageIndex: 4),
      (label: "III · Works", pageIndex: 6),
      (label: "IV · Labs", pageIndex: 7),
      (label: "Epilogue", pageIndex: 8),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: _leatherCover.withValues(alpha: 0.92),
        border: const Border(
          bottom: BorderSide(color: _leatherBorder, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Book Icon & Title
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _goldFoil.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _goldFoil.withValues(alpha: 0.5)),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: _goldFoil,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          if (!isCompact) ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.fullName.isNotEmpty
                        ? "${profile.fullName} · Chronicle"
                        : "The Developer's Chronicle",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xffFDF8EE),
                    ),
                  ),
                  const Text(
                    "Swipe left or right to turn pages",
                    style: TextStyle(
                      fontSize: 10.5,
                      color: _goldFoil,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Bookmark Ribbons
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final bm in bookmarks)
                    Builder(
                      builder: (context) {
                        final targetUnit = isDualPageSpread
                            ? (bm.pageIndex ~/ 2)
                            : bm.pageIndex;
                        final isSelected = _currentUnitIndex == targetUnit;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => _goToUnit(targetUnit, totalUnits),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _crimsonRibbon
                                    : Colors.black.withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? _goldFoil
                                      : _leatherBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bookmark_rounded,
                                    size: 13,
                                    color: isSelected
                                        ? _goldFoil
                                        : const Color(0xffD6C7B2),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    bm.label,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xffE5D9C5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),
          // Paper Theme Toggle (Warm Parchment vs Night Paper)
          IconButton(
            tooltip: _isNightPaper
                ? "Switch to Warm Parchment Paper"
                : "Switch to Dark Ink Reading Mode",
            onPressed: () => setState(() => _isNightPaper = !_isNightPaper),
            icon: Icon(
              _isNightPaper
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round,
              size: 18,
              color: _goldFoil,
            ),
          ),
          const SizedBox(width: 4),
          // Template Switcher Menu
          TemplateSwitcherButton(compact: isCompact),
        ],
      ),
    );
  }

  // ===========================================================================
  // PHYSICAL LEATHER-BOUND BOOK FRAME & 3D SWIPEABLE PAGEVIEW
  // ===========================================================================

  Widget _buildPhysicalBookFrame({
    required List<_BookPageData> allPages,
    required bool isDualPageSpread,
    required int totalUnits,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _leatherCover,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _goldFoil.withValues(alpha: 0.55), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDualPageSpread ? 14 : 8,
        vertical: isDualPageSpread ? 12 : 8,
      ),
      child: Container(
        // Stacked multi-page paper block edge effect
        decoration: BoxDecoration(
          color: _paperBgAlt,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _paperBorder, width: 2),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isDualPageSpread ? 6 : 3,
          vertical: 4,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ScrollConfiguration(
            behavior: const _BookSwipeScrollBehavior(),
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: totalUnits,
              onPageChanged: (idx) {
                setState(() {
                  _currentUnitIndex = idx;
                });
              },
              itemBuilder: (context, unitIndex) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double pageOffset = 0.0;
                    if (_pageController.position.haveDimensions) {
                      pageOffset =
                          (_pageController.page ?? _currentUnitIndex.toDouble()) -
                              unitIndex;
                    }
                    final clamped = pageOffset.clamp(-1.0, 1.0);
                    // 3D book page rotation & perspective during swipe
                    final angle = clamped * -0.42;
                    final matrix = Matrix4.identity()
                      ..setEntry(3, 2, 0.0011)
                      ..rotateY(angle);

                    return Transform(
                      transform: matrix,
                      alignment: clamped >= 0
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: child,
                    );
                  },
                  child: isDualPageSpread
                      ? _buildDualPageSpread(
                          allPages: allPages,
                          spreadIndex: unitIndex,
                          totalUnits: totalUnits,
                        )
                      : _buildSinglePageLeaf(
                          page: allPages[unitIndex],
                          unitIndex: unitIndex,
                          totalUnits: totalUnits,
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Renders a Two-Page Open Book Spread (Left Page + Center Spine + Right Page).
  Widget _buildDualPageSpread({
    required List<_BookPageData> allPages,
    required int spreadIndex,
    required int totalUnits,
  }) {
    final leftIdx = spreadIndex * 2;
    final rightIdx = leftIdx + 1;
    final leftPage = allPages[leftIdx];
    final rightPage = rightIdx < allPages.length ? allPages[rightIdx] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LEFT PAGE (VERSO)
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildBookPageSheet(
                  page: leftPage,
                  isLeftPage: true,
                  canTurnPrev: spreadIndex > 0,
                  canTurnNext: false,
                  onTurnPrev: () => _prevUnit(totalUnits),
                  onTurnNext: () => _nextUnit(totalUnits),
                ),
              ),
              // Subtle inner spine shadow on the right edge of the left page
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: 28,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(
                            alpha: _isNightPaper ? 0.45 : 0.12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // CENTER BOOK SPINE CREASE
        Container(
          width: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.35),
                _goldFoil.withValues(alpha: 0.4),
                Colors.black.withValues(alpha: 0.35),
              ],
            ),
          ),
        ),

        // RIGHT PAGE (RECTO)
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: rightPage != null
                    ? _buildBookPageSheet(
                        page: rightPage,
                        isLeftPage: false,
                        canTurnPrev: false,
                        canTurnNext: spreadIndex < totalUnits - 1,
                        onTurnPrev: () => _prevUnit(totalUnits),
                        onTurnNext: () => _nextUnit(totalUnits),
                      )
                    : Container(color: _paperBg),
              ),
              // Subtle inner spine shadow on the left edge of the right page
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: 28,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(
                            alpha: _isNightPaper ? 0.45 : 0.12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Renders a Single Book Page on mobile/tablet portrait screens.
  Widget _buildSinglePageLeaf({
    required _BookPageData page,
    required int unitIndex,
    required int totalUnits,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: _buildBookPageSheet(
            page: page,
            isLeftPage: false,
            canTurnPrev: unitIndex > 0,
            canTurnNext: unitIndex < totalUnits - 1,
            onTurnPrev: () => _prevUnit(totalUnits),
            onTurnNext: () => _nextUnit(totalUnits),
          ),
        ),
        // Subtle binding shadow on the left edge
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          width: 18,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(
                      alpha: _isNightPaper ? 0.4 : 0.1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Individual book page layout with Running Header, Scrollable Page Content,
  /// and Page Number + Interactive Corner Turn Footer.
  Widget _buildBookPageSheet({
    required _BookPageData page,
    required bool isLeftPage,
    required bool canTurnPrev,
    required bool canTurnNext,
    required VoidCallback onTurnPrev,
    required VoidCallback onTurnNext,
  }) {
    return Container(
      color: _paperBg,
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Running Book Header
          Row(
            children: [
              if (isLeftPage) ...[
                Text(
                  "PAGE ${page.pageNumber}",
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: _inkMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    page.chapterTag,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: _accentInk,
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    page.chapterTag,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: _accentInk,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "PAGE ${page.pageNumber}",
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: _inkMuted,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Divider(color: _paperBorder, height: 1),
          const SizedBox(height: 16),

          // Scrollable Page Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: 4, bottom: 8),
              child: page.builder(context),
            ),
          ),

          const SizedBox(height: 8),
          Divider(color: _paperBorder, height: 1),
          const SizedBox(height: 8),

          // Page Footer with Page Number & Interactive Page-Corner Turn Triggers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (canTurnPrev)
                InkWell(
                  onTap: onTurnPrev,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.turn_left_rounded,
                          size: 14,
                          color: _accentInk,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Prev Page",
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _accentInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(width: 60),
              Text(
                "— ${page.pageNumber} —",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: _inkMuted,
                ),
              ),
              if (canTurnNext)
                InkWell(
                  onTap: onTurnNext,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Turn Page",
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _accentInk,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.turn_right_rounded,
                          size: 14,
                          color: _accentInk,
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(width: 60),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM READER NAVIGATION BAR
  // ===========================================================================

  Widget _buildReaderBottomBar({
    required ProfileData profile,
    required List<_BookPageData> allPages,
    required bool isDualPageSpread,
    required int totalUnits,
    required double screenW,
  }) {
    final isCompact = screenW < 640;
    final leftPageNum = isDualPageSpread
        ? (_currentUnitIndex * 2 + 1)
        : (_currentUnitIndex + 1);
    final rightPageNum = isDualPageSpread
        ? math.min(allPages.length, leftPageNum + 1)
        : leftPageNum;
    final pageLabel = isDualPageSpread && leftPageNum != rightPageNum
        ? "Pages $leftPageNum–$rightPageNum of ${allPages.length}"
        : "Page $leftPageNum of ${allPages.length}";

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _leatherCover.withValues(alpha: 0.94),
        border: const Border(
          top: BorderSide(color: _leatherBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Page Button
          TextButton.icon(
            onPressed: _currentUnitIndex > 0
                ? () => _prevUnit(totalUnits)
                : null,
            style: TextButton.styleFrom(
              foregroundColor: _goldFoil,
              disabledForegroundColor: _leatherBorder,
            ),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
            label: Text(
              isCompact ? "Prev" : "Previous Page",
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
            ),
          ),

          // Center Page Indicator Dots & Secret 5-Tap Version Trigger
          Flexible(
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < totalUnits; i++)
                      GestureDetector(
                        onTap: () => _goToUnit(i, totalUnits),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentUnitIndex == i ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _currentUnitIndex == i
                                ? _goldBright
                                : _leatherBorder,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  pageLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xffE5D9C5),
                  ),
                ),
                if (!isCompact) ...[
                  const Text("•", style: TextStyle(color: _leatherBorder)),
                  const SecretVersionTrigger(
                    versionText: "Version ${PortfolioRepository.appVersion}",
                    textStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xffA89882),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Next Page Button
          TextButton.icon(
            onPressed: _currentUnitIndex < totalUnits - 1
                ? () => _nextUnit(totalUnits)
                : null,
            style: TextButton.styleFrom(
              foregroundColor: _goldFoil,
              disabledForegroundColor: _leatherBorder,
            ),
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            label: Text(
              isCompact ? "Next" : "Next Page",
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PAGE CONTENT BUILDERS (PAGES 1 TO 10)
  // ===========================================================================

  Widget _buildBookChapterOrnament(String chapterNum, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chapterNum.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: _accentInk,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _inkTitle,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(width: 42, height: 2.5, color: _accentInk),
            const SizedBox(width: 6),
            Icon(Icons.auto_awesome, size: 12, color: _accentInk),
            const SizedBox(width: 6),
            Expanded(child: Container(height: 1, color: _paperBorder)),
          ],
        ),
      ],
    );
  }

  // PAGE 1: FRONTISPIECE (Portrait, Ex Libris Seal, Quick Stats)
  Widget _buildFrontispiecePage(ProfileData profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _paperBgAlt,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _paperBorder),
          ),
          child: Text(
            "EX LIBRIS · DEVELOPER EDITION",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: _accentInk,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Framed Portrait Illustration
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _paperBgAlt,
            shape: BoxShape.circle,
            border: Border.all(color: _goldFoil, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: PortfolioImage(
              imagePath: profile.avatarImage,
              width: 148,
              height: 148,
              fit: BoxFit.cover,
              forLightSurface: !_isNightPaper,
              fallbackIcon: Icons.person_rounded,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: _inkTitle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.roleTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: _accentInk,
          ),
        ),
        if (profile.location.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.place_outlined, size: 14, color: _inkMuted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  profile.location,
                  style: TextStyle(fontSize: 12.5, color: _inkMuted),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        if (profile.stats.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: _paperBgAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _paperBorder),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceAround,
              children: [
                for (final s in profile.stats)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.value,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: _accentInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _inkMuted,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }

  // PAGE 2: PROLOGUE (Narrative Bio, Drop-Cap Style Intro, Actions)
  Widget _buildProloguePage(ProfileData profile, PortfolioRepository repo) {
    final bio = profile.bio.trim();
    final firstLetter = bio.isNotEmpty ? bio.substring(0, 1) : "W";
    final restBio = bio.length > 1 ? bio.substring(1) : bio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookChapterOrnament(
          profile.greeting.isNotEmpty ? profile.greeting : "PROLOGUE",
          profile.storybookSubtitle.isNotEmpty
              ? profile.storybookSubtitle
              : "A Chronicle of Engineering & Craft",
        ),
        const SizedBox(height: 16),
        if (profile.isAvailable && profile.availabilityText.trim().isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff10B981).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xff10B981).withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              "● ${profile.availabilityText}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _isNightPaper
                    ? const Color(0xff34D399)
                    : const Color(0xff047857),
              ),
            ),
          ),

        // Editorial Drop-Cap Paragraph
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12, top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _accentInk.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accentInk.withValues(alpha: 0.45)),
              ),
              child: Text(
                firstLetter,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: _accentInk,
                  height: 1.0,
                ),
              ),
            ),
            Expanded(
              child: Text(
                restBio,
                style: TextStyle(
                  fontSize: 14.5,
                  color: _inkBody,
                  height: 1.65,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _paperBgAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _paperBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.swipe_rounded, size: 17, color: _accentInk),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "How to Read This Book",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _inkTitle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Swipe left or right across any page (with touch or mouse drag), press your keyboard's Left/Right arrow keys, or tap the chapter bookmarks above.",
                style: TextStyle(
                  fontSize: 12.5,
                  color: _inkMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        if (profile.resumeUrl.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _openUrl(profile.resumeUrl),
            style: OutlinedButton.styleFrom(
              foregroundColor: _accentInk,
              side: BorderSide(color: _accentInk),
            ),
            icon: const Icon(Icons.menu_book_rounded, size: 16),
            label: const Text(
              "Open Curriculum Vitae / Resume",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ],
    );
  }

  // PAGE 3: CHAPTER I (PART A) — WORK EXPERIENCES
  Widget _buildExperiencePage(PortfolioRepository repo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookChapterOrnament(
          "Chapter I · Part A",
          "Professional Journey",
        ),
        const SizedBox(height: 16),
        for (final exp in repo.experiences)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _paperBgAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _paperBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      exp.role,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: _inkTitle,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _accentInk.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exp.period,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _accentInk,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  exp.company,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _inkMuted,
                  ),
                ),
                if (exp.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    exp.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: _inkBody,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  // PAGE 4: CHAPTER I (PART B) — EDUCATION & MILESTONES
  Widget _buildEducationPage(PortfolioRepository repo, ProfileData profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookChapterOrnament(
          "Chapter I · Part B",
          "Academic Foundation",
        ),
        const SizedBox(height: 16),
        for (final edu in repo.educations)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _paperBgAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _paperBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu.period,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: _accentInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  edu.degree,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _inkTitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  edu.institution,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: _inkBody,
                    height: 1.4,
                  ),
                ),
                if (edu.honors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    "✦ ${edu.honors}",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _accentInk,
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _paperBgAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _paperBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DEVELOPER'S NOTE",
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: _accentInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "\"Every application is a story written in architecture, clean state management, and responsive user experience.\"",
                style: TextStyle(
                  fontSize: 13.5,
                  fontStyle: FontStyle.italic,
                  color: _inkBody,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // PAGE 5: CHAPTER II (PART A) — PLATFORMS
  Widget _buildPlatformsPage(PortfolioRepository repo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookChapterOrnament(
          "Chapter II · Part A",
          "Cross-Platform Realms",
        ),
        const SizedBox(height: 10),
        Text(
          "Target ecosystems and device form-factors engineered from a unified architecture.",
          style: TextStyle(fontSize: 13, color: _inkMuted, height: 1.45),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final plat in repo.platforms)
              Container(
                width: 210,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _paperBgAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _paperBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _paperBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _paperBorder),
                      ),
                      child: PortfolioImage(
                        imagePath: plat.img,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        forLightSurface: !_isNightPaper,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        plat.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _inkTitle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // PAGE 6: CHAPTER II (PART B) — CATEGORIZED SKILLS
  Widget _buildSkillsPage(PortfolioRepository repo) {
    final filtered = _selectedSkillCat == "All Tools"
        ? repo.skills
        : repo.skills
            .where((s) =>
                s.category.toLowerCase() == _selectedSkillCat.toLowerCase())
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookChapterOrnament(
          "Chapter II · Part B",
          "The Craftsman's Arsenal",
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final cat in skillCategories)
              InkWell(
                onTap: () => setState(() => _selectedSkillCat = cat),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedSkillCat == cat ? _accentInk : _paperBgAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          _selectedSkillCat == cat ? _accentInk : _paperBorder,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color:
                          _selectedSkillCat == cat ? Colors.white : _inkTitle,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in filtered)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _paperBgAlt,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: _paperBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PortfolioImage(
                      imagePath: skill.img,
                      width: 17,
                      height: 17,
                      fit: BoxFit.contain,
                      forLightSurface: !_isNightPaper,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      skill.title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _inkTitle,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // PAGES 7 & 8: CHAPTERS III & IV — PROJECTS
  Widget _buildProjectsPage({
    required String title,
    required String subtitle,
    required List<ProjectUtils> projects,
    required String badgeLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookChapterOrnament(badgeLabel, title),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12.5, color: _inkMuted, height: 1.4),
        ),
        const SizedBox(height: 14),
        for (final proj in projects)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: _paperBgAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _paperBorder),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showBookProjectDetailDialog(proj),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: PortfolioImage(
                              imagePath: proj.image,
                              width: 78,
                              height: 62,
                              fit: BoxFit.cover,
                              forLightSurface: !_isNightPaper,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      proj.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: _inkTitle,
                                      ),
                                    ),
                                    if (proj.category.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _accentInk.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          proj.category,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: _accentInk,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  proj.subtitle.isNotEmpty
                                      ? proj.subtitle
                                      : proj.detail,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _inkBody,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (proj.techStack.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            for (final t in proj.techStack)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _paperBg,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: _paperBorder),
                                ),
                                child: Text(
                                  t,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: _inkMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Divider(color: _paperBorder, height: 1),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            children: [
                              if (proj.githubLink != null)
                                InkWell(
                                  onTap: () => _openUrl(proj.githubLink),
                                  child: Text(
                                    "GitHub ↗",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _inkMuted,
                                    ),
                                  ),
                                ),
                              if (proj.webLink != null)
                                InkWell(
                                  onTap: () => _openUrl(proj.webLink),
                                  child: Text(
                                    "Live Web ↗",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _inkMuted,
                                    ),
                                  ),
                                ),
                              if (proj.androidLink != null)
                                InkWell(
                                  onTap: () => _openUrl(proj.androidLink),
                                  child: Text(
                                    "Android ↗",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _inkMuted,
                                    ),
                                  ),
                                ),
                              if (proj.iosLink != null)
                                InkWell(
                                  onTap: () => _openUrl(proj.iosLink),
                                  child: Text(
                                    "iOS ↗",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _inkMuted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          InkWell(
                            onTap: () => _showBookProjectDetailDialog(proj),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: 13.5,
                                    color: _accentInk,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Read Details →",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _accentInk,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showBookProjectDetailDialog(ProjectUtils proj) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = (screenHeight * 0.28).clamp(135.0, 220.0);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _paperBg,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _goldFoil, width: 1.5),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: PortfolioImage(
                          imagePath: proj.image,
                          width: double.infinity,
                          height: bannerHeight,
                          fit: BoxFit.cover,
                          forLightSurface: !_isNightPaper,
                        ),
                      ),
                      if (proj.category.isNotEmpty)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _leatherCover.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _goldFoil),
                            ),
                            child: Text(
                              proj.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: _goldFoil,
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
                                _leatherCover.withValues(alpha: 0.88),
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
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
                          "CHAPTER CASE STUDY",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                            color: _accentInk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proj.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _inkTitle,
                          ),
                        ),
                        if (proj.subtitle.trim().isNotEmpty &&
                            proj.subtitle.trim() != proj.detail.trim()) ...[
                          const SizedBox(height: 6),
                          Text(
                            proj.subtitle,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _inkMuted,
                              height: 1.45,
                            ),
                          ),
                        ],
                        if (proj.techStack.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final tech in proj.techStack)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _accentInk.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _accentInk.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    tech,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _accentInk,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 18),
                        Text(
                          "CHRONICLE OVERVIEW",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: _inkMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          proj.detail.isNotEmpty ? proj.detail : proj.subtitle,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: _inkBody,
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Divider(color: _paperBorder),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.end,
                          children: [
                            if (proj.githubLink != null)
                              OutlinedButton.icon(
                                onPressed: () => _openUrl(proj.githubLink),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _inkTitle,
                                  side: BorderSide(color: _paperBorder),
                                ),
                                icon: const Icon(Icons.code_rounded, size: 16),
                                label: const Text("View on GitHub"),
                              ),
                            if (proj.webLink != null)
                              ElevatedButton.icon(
                                onPressed: () => _openUrl(proj.webLink),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentInk,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(
                                  Icons.language_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  "Visit Live Website",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            if (proj.androidLink != null)
                              OutlinedButton.icon(
                                onPressed: () => _openUrl(proj.androidLink),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _inkTitle,
                                  side: BorderSide(color: _paperBorder),
                                ),
                                icon:
                                    const Icon(Icons.android_rounded, size: 16),
                                label: const Text("Android App"),
                              ),
                            if (proj.iosLink != null)
                              OutlinedButton.icon(
                                onPressed: () => _openUrl(proj.iosLink),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _inkTitle,
                                  side: BorderSide(color: _paperBorder),
                                ),
                                icon: const Icon(Icons.apple_rounded, size: 16),
                                label: const Text("iOS App"),
                              ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: Text(
                                "Close Story",
                                style: TextStyle(
                                  color: _accentInk,
                                  fontWeight: FontWeight.w800,
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

  // PAGE 9: EPILOGUE (PART A) — DIRECT CHANNELS & SOCIAL BOOKMARKS
  Widget _buildContactChannelsPage(ProfileData profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBookChapterOrnament(
          "Epilogue · Part A",
          "Correspondence & Channels",
        ),
        const SizedBox(height: 12),
        Text(
          "Reach out directly to discuss engineering roles, product collaborations, or consulting.",
          style: TextStyle(fontSize: 13.5, color: _inkBody, height: 1.55),
        ),
        const SizedBox(height: 18),
        if (profile.email.isNotEmpty)
          _buildContactBookmarkTile(
            icon: Icons.mail_outline_rounded,
            label: "Electronic Mail (Tap to Copy)",
            value: profile.email,
            onTap: () {
              Clipboard.setData(ClipboardData(text: profile.email));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Email copied to clipboard!")),
              );
            },
          ),
        if (profile.phone.isNotEmpty)
          _buildContactBookmarkTile(
            icon: Icons.phone_outlined,
            label: "Direct Telephone (Tap to Copy)",
            value: profile.phone,
            onTap: () {
              Clipboard.setData(ClipboardData(text: profile.phone));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Phone copied to clipboard!")),
              );
            },
          ),
        if (profile.location.isNotEmpty)
          _buildContactBookmarkTile(
            icon: Icons.location_on_outlined,
            label: "Base of Operations",
            value: profile.location,
          ),
        const SizedBox(height: 14),
        Text(
          "SOCIAL BOOKMARKS",
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: _accentInk,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in profile.snsLinks.entries)
              if (entry.value.trim().isNotEmpty)
                ActionChip(
                  backgroundColor: _paperBgAlt,
                  side: BorderSide(color: _paperBorder),
                  label: Text(
                    entry.key.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _inkTitle,
                    ),
                  ),
                  onPressed: () => _openUrl(entry.value),
                ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactBookmarkTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: _paperBgAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _paperBorder),
          ),
          child: Row(
            children: [
              Icon(icon, color: _accentInk, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 11, color: _inkMuted),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _inkTitle,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.copy_rounded, size: 15, color: _inkMuted),
            ],
          ),
        ),
      ),
    );
  }

  // PAGE 10: EPILOGUE (PART B) — CONTACT FORM & BOOK COLOPHON
  Widget _buildContactFormAndColophonPage(
    ProfileData profile,
    PortfolioRepository repo,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookChapterOrnament(
            "Epilogue · Part B",
            "Write the Next Chapter",
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nameCtrl,
            style: TextStyle(color: _inkTitle, fontSize: 13.5),
            decoration: _bookInputDecoration("Your Name"),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Enter your name" : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailCtrl,
            style: TextStyle(color: _inkTitle, fontSize: 13.5),
            decoration: _bookInputDecoration("Your Email"),
            validator: (v) =>
                (v == null || !v.contains('@')) ? "Enter a valid email" : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _msgCtrl,
            maxLines: 3,
            style: TextStyle(color: _inkTitle, fontSize: 13.5),
            decoration: _bookInputDecoration("Your Message"),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Enter a message" : null,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSending
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _isSending = true);
                      final res = await repo.submitContactMessage(
                        name: _nameCtrl.text,
                        email: _emailCtrl.text,
                        message: _msgCtrl.text,
                      );
                      if (!mounted) return;
                      setState(() => _isSending = false);
                      _nameCtrl.clear();
                      _emailCtrl.clear();
                      _msgCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res)),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentInk,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(
                _isSending ? "Inscribing..." : "Send Correspondence",
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Book Colophon Seal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _paperBgAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _paperBorder),
            ),
            child: Column(
              children: [
                Text(
                  "COLOPHON",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    color: _accentInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.footerText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _inkBody,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "© ${DateTime.now().year} ${profile.fullName}",
                      style: TextStyle(fontSize: 11, color: _inkMuted),
                    ),
                    Text("•", style: TextStyle(color: _inkMuted)),
                    SecretVersionTrigger(
                      versionText: "Version ${PortfolioRepository.appVersion}",
                      textStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _inkMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _bookInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _inkMuted, fontSize: 12.5),
      filled: true,
      fillColor: _paperBgAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _paperBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _accentInk, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
