import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_porfolio/constants/skill_items.dart';
import 'package:my_porfolio/models/portfolio_models.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/utils/project_utils.dart';
import 'package:my_porfolio/widgets/admin_passcode_dialog.dart';
import 'package:my_porfolio/widgets/back_to_top_button.dart';
import 'package:my_porfolio/widgets/portfolio_image.dart';
import 'package:my_porfolio/widgets/template_switcher_menu.dart';
import 'package:url_launcher/url_launcher.dart';

/// Template 2: Modern Bento Grid & Glassmorphism (Cyber Neon / Dark Tech Grid)
class BentoTemplateView extends StatefulWidget {
  const BentoTemplateView({super.key});

  @override
  State<BentoTemplateView> createState() => _BentoTemplateViewState();
}

class _BentoTemplateViewState extends State<BentoTemplateView> {
  static const Color _bgCanvas = Color(0xff070A10);
  static const Color _bentoSurface = Color(0xff101624);
  static const Color _bentoSurfaceAlt = Color(0xff161E31);
  static const Color _bentoBorder = Color(0xff23304D);
  static const Color _cyanAccent = Color(0xff22D3EE);
  static const Color _violetAccent = Color(0xffA855F7);
  static const Color _textWhite = Color(0xffF8FAFC);
  static const Color _textMuted = Color(0xff94A3B8);

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(5, (_) => GlobalKey());
  String _selectedSkillCat = skillCategories.first;
  String _selectedProjCat = 'All';

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _scrollTo(int index) {
    if (index < 0 || index >= _sectionKeys.length) return;
    final ctx = _sectionKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  BoxDecoration _bentoBox({
    bool highlight = false,
    Gradient? gradient,
    double radius = 22,
  }) {
    return BoxDecoration(
      color: gradient == null ? _bentoSurface : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: highlight ? _cyanAccent.withValues(alpha: 0.65) : _bentoBorder,
        width: highlight ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: highlight
              ? _cyanAccent.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.4),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioRepository.instance;
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final profile = repo.profile;
        final size = MediaQuery.of(context).size;
        final isMobile = size.width < 700;

        return Scaffold(
          backgroundColor: _bgCanvas,
          floatingActionButton: BackToTopButton(
            scrollController: _scrollController,
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildFloatingBentoNav(profile, isMobile),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 28,
                      vertical: 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SECTION 0: BENTO DASHBOARD HERO
                            SizedBox(key: _sectionKeys[0]),
                            _buildHeroBentoGrid(profile, repo, isMobile),
                            const SizedBox(height: 44),

                            // SECTION 1: TECH STACK MATRIX BENTO
                            SizedBox(key: _sectionKeys[1]),
                            _buildTechStackBento(repo, isMobile),
                            const SizedBox(height: 44),

                            // SECTION 2: PROJECTS BENTO SHOWCASE
                            SizedBox(key: _sectionKeys[2]),
                            _buildProjectsBento(repo, isMobile),
                            const SizedBox(height: 44),

                            // SECTION 3: EXPERIENCE & EDUCATION BENTO
                            SizedBox(key: _sectionKeys[3]),
                            _buildJourneyBento(repo, isMobile),
                            const SizedBox(height: 44),

                            // SECTION 4: CONTACT BENTO TERMINAL
                            SizedBox(key: _sectionKeys[4]),
                            _buildContactBento(profile, repo, isMobile),
                            const SizedBox(height: 36),

                            // FOOTER WITH 5-TAP SECRET VERSION TRIGGER
                            _buildBentoFooter(profile),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingBentoNav(ProfileData profile, bool isMobile) {
    const items = ['Bento', 'Stack', 'Projects', 'Journey', 'Contact'];
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 12 : 24,
        10,
        isMobile ? 12 : 24,
        6,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _bentoSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _bentoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_cyanAccent, _violetAccent],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              size: 17,
              color: _bgCanvas,
            ),
          ),
          const SizedBox(width: 10),
          if (!isMobile)
            Text(
              profile.fullName,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: _textWhite,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => _scrollTo(i),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _bentoSurfaceAlt,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _cyanAccent.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            items[i],
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _textWhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          TemplateSwitcherButton(compact: isMobile),
        ],
      ),
    );
  }

  Widget _buildHeroBentoGrid(
    ProfileData profile,
    PortfolioRepository repo,
    bool isMobile,
  ) {
    final mainHeroTile = Container(
      padding: EdgeInsets.all(isMobile ? 22 : 32),
      decoration: _bentoBox(
        highlight: true,
        gradient: const LinearGradient(
          colors: [_bentoSurface, _bentoSurfaceAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _cyanAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cyanAccent.withValues(alpha: 0.5)),
                ),
                child: const Text(
                  "BENTO WORKSPACE · v1.0",
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: _cyanAccent,
                  ),
                ),
              ),
              if (profile.isAvailable &&
                  profile.availabilityText.trim().isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xff10B981).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "● ${profile.availabilityText}",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff34D399),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: isMobile ? 68 : 88,
                height: isMobile ? 68 : 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _cyanAccent, width: 2.5),
                ),
                child: ClipOval(
                  child: PortfolioImage(
                    imagePath: profile.avatarImage,
                    width: isMobile ? 68 : 88,
                    height: isMobile ? 68 : 88,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.person_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.greeting,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _cyanAccent,
                      ),
                    ),
                    Text(
                      profile.fullName,
                      style: TextStyle(
                        fontSize: isMobile ? 26 : 36,
                        fontWeight: FontWeight.w900,
                        color: _textWhite,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.roleTitle,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: FontWeight.w700,
                        color: _violetAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            profile.bio,
            style: const TextStyle(
              fontSize: 14.5,
              color: _textMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => _scrollTo(2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cyanAccent,
                  foregroundColor: _bgCanvas,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.rocket_launch_rounded, size: 17),
                label: const Text(
                  "Explore Works",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _scrollTo(4),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textWhite,
                  side: const BorderSide(color: _bentoBorder),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.bolt_rounded,
                  size: 17,
                  color: _cyanAccent,
                ),
                label: const Text(
                  "Connect",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final statsAndRealmsColumn = Column(
      children: [
        // Stats Bento Row
        if (profile.stats.isNotEmpty)
          Row(
            children: [
              for (int i = 0; i < profile.stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 12,
                    ),
                    decoration: _bentoBox(),
                    child: Column(
                      children: [
                        Text(
                          profile.stats[i].value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _cyanAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.stats[i].label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        const SizedBox(height: 14),
        // Platform Realms Bento Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _bentoBox(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TARGET REALMS",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: _cyanAccent,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final plat in repo.platforms)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _bentoSurfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _bentoBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PortfolioImage(
                            imagePath: plat.img,
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            plat.title,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _textWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          mainHeroTile,
          const SizedBox(height: 14),
          statsAndRealmsColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: mainHeroTile),
        const SizedBox(width: 16),
        Expanded(flex: 5, child: statsAndRealmsColumn),
      ],
    );
  }

  Widget _buildTechStackBento(PortfolioRepository repo, bool isMobile) {
    final skills = _selectedSkillCat == "All Tools"
        ? repo.skills
        : repo.skills
            .where((s) =>
                s.category.toLowerCase() == _selectedSkillCat.toLowerCase())
            .toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: _bentoBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TECH STACK MATRIX",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: _cyanAccent,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Languages, Frameworks & Cloud Tools",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _textWhite,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cat in skillCategories)
                    ChoiceChip(
                      label: Text(cat),
                      selected: _selectedSkillCat == cat,
                      onSelected: (_) =>
                          setState(() => _selectedSkillCat = cat),
                      selectedColor: _cyanAccent,
                      backgroundColor: _bentoSurfaceAlt,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            _selectedSkillCat == cat ? _bgCanvas : _textWhite,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final s in skills)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: _bentoSurfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _cyanAccent.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PortfolioImage(
                        imagePath: s.img,
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: _textWhite,
                            ),
                          ),
                          Text(
                            s.category,
                            style: const TextStyle(
                              fontSize: 10,
                              color: _cyanAccent,
                            ),
                          ),
                        ],
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

  Widget _buildProjectsBento(PortfolioRepository repo, bool isMobile) {
    final all = [...repo.workProjects, ...repo.hobbyProjects];
    final filtered = _selectedProjCat == 'All'
        ? all
        : all
            .where((p) =>
                p.category.toLowerCase() == _selectedProjCat.toLowerCase())
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BENTO SHOWCASE",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: _cyanAccent,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Featured Work & Hobby Projects",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: _textWhite,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final cat in ['All', 'Mobile App', 'Web Platform'])
                  ChoiceChip(
                    label: Text(cat),
                    selected: _selectedProjCat == cat,
                    onSelected: (_) => setState(() => _selectedProjCat = cat),
                    selectedColor: _cyanAccent,
                    backgroundColor: _bentoSurface,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _selectedProjCat == cat ? _bgCanvas : _textWhite,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 980
                ? 3
                : constraints.maxWidth >= 600
                    ? 2
                    : 1;
            final cardWidth = cols == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - (16 * (cols - 1))) / cols;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final proj in filtered)
                  SizedBox(
                    width: cardWidth,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: _bentoBox(radius: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              PortfolioImage(
                                imagePath: proj.image,
                                width: cardWidth,
                                height: 170,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _bgCanvas.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          _cyanAccent.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Text(
                                    proj.projectType.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: _cyanAccent,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _bgCanvas.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    proj.category,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: _textWhite,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  proj.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: _textWhite,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  proj.subtitle,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _textMuted,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final t in proj.techStack.take(4))
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _bentoSurfaceAlt,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          t,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: _cyanAccent,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    if (proj.githubLink != null)
                                      IconButton(
                                        onPressed: () =>
                                            _openUrl(proj.githubLink),
                                        icon: const Icon(
                                          Icons.code_rounded,
                                          color: _textWhite,
                                          size: 19,
                                        ),
                                      ),
                                    if (proj.webLink != null)
                                      IconButton(
                                        onPressed: () => _openUrl(proj.webLink),
                                        icon: const Icon(
                                          Icons.language_rounded,
                                          color: _cyanAccent,
                                          size: 19,
                                        ),
                                      ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () =>
                                          _showBentoProjectDialog(proj),
                                      child: const Text(
                                        "Inspect →",
                                        style: TextStyle(
                                          color: _cyanAccent,
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
              ],
            );
          },
        ),
      ],
    );
  }

  void _showBentoProjectDialog(ProjectUtils proj) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _bentoSurface,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: _bentoBorder),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: PortfolioImage(
                      imagePath: proj.image,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    proj.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _textWhite,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in proj.techStack)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _cyanAccent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _cyanAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    proj.detail,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: _textMuted,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: _cyanAccent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

  Widget _buildJourneyBento(PortfolioRepository repo, bool isMobile) {
    final expTile = Container(
      padding: const EdgeInsets.all(24),
      decoration: _bentoBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "EXPERIENCE LOG",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: _cyanAccent,
            ),
          ),
          const SizedBox(height: 16),
          for (final exp in repo.experiences)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _bentoSurfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: exp.isCurrent
                      ? _cyanAccent.withValues(alpha: 0.5)
                      : _bentoBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.period,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _cyanAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exp.role,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: _textWhite,
                    ),
                  ),
                  Text(
                    exp.company,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: _textMuted,
                    ),
                  ),
                  if (exp.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      exp.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );

    final eduTile = Container(
      padding: const EdgeInsets.all(24),
      decoration: _bentoBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "EDUCATION & HONORS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: _violetAccent,
            ),
          ),
          const SizedBox(height: 16),
          for (final edu in repo.educations)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _bentoSurfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _violetAccent.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    edu.period,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _violetAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    edu.degree,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    edu.institution,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: _textMuted,
                    ),
                  ),
                  if (edu.honors.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      "✦ ${edu.honors}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff34D399),
                      ),
                    ),
                  ],
                  if (edu.coursework.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final c in edu.coursework)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _bgCanvas,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              c,
                              style: const TextStyle(
                                fontSize: 11,
                                color: _textMuted,
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

    if (isMobile) {
      return Column(
        children: [
          expTile,
          const SizedBox(height: 16),
          eduTile,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: expTile),
        const SizedBox(width: 16),
        Expanded(flex: 5, child: eduTile),
      ],
    );
  }

  Widget _buildContactBento(
    ProfileData profile,
    PortfolioRepository repo,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      decoration: _bentoBox(highlight: true),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "DIRECT TRANSMISSION",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: _cyanAccent,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Get In Touch",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _textWhite,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                if (profile.email.isNotEmpty)
                  ActionChip(
                    backgroundColor: _bentoSurfaceAlt,
                    avatar: const Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: _cyanAccent,
                    ),
                    label: Text(
                      profile.email,
                      style: const TextStyle(color: _textWhite),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: profile.email));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Copied ${profile.email}")),
                      );
                    },
                  ),
                if (profile.phone.isNotEmpty)
                  ActionChip(
                    backgroundColor: _bentoSurfaceAlt,
                    avatar: const Icon(
                      Icons.phone_in_talk_outlined,
                      size: 16,
                      color: _cyanAccent,
                    ),
                    label: Text(
                      profile.phone,
                      style: const TextStyle(color: _textWhite),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: profile.phone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Copied ${profile.phone}")),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: _textWhite),
              decoration: InputDecoration(
                labelText: "Your Name",
                filled: true,
                fillColor: _bgCanvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Enter your name" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              style: const TextStyle(color: _textWhite),
              decoration: InputDecoration(
                labelText: "Your Email",
                filled: true,
                fillColor: _bgCanvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) => (v == null || !v.contains('@'))
                  ? "Enter a valid email"
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _msgCtrl,
              maxLines: 4,
              style: const TextStyle(color: _textWhite),
              decoration: InputDecoration(
                labelText: "Your Message",
                filled: true,
                fillColor: _bgCanvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Enter a message" : null,
            ),
            const SizedBox(height: 16),
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
                  backgroundColor: _cyanAccent,
                  foregroundColor: _bgCanvas,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 17),
                label: const Text(
                  "Send Transmission",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoFooter(ProfileData profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            profile.footerText,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _textMuted, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "© ${DateTime.now().year} ${profile.fullName}",
                style: const TextStyle(color: _textMuted, fontSize: 12),
              ),
              const Text("•", style: TextStyle(color: _textMuted)),
              const SecretVersionTrigger(
                versionText: "Version ${PortfolioRepository.appVersion}",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
