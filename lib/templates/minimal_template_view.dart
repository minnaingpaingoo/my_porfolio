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

/// Template 3: Minimalist Executive Light / Split-Screen Magazine Layout
class MinimalTemplateView extends StatefulWidget {
  const MinimalTemplateView({super.key});

  @override
  State<MinimalTemplateView> createState() => _MinimalTemplateViewState();
}

class _MinimalTemplateViewState extends State<MinimalTemplateView> {
  static const Color _bgPaper = Color(0xffF8FAFC);
  static const Color _cardWhite = Color(0xffFFFFFF);
  static const Color _borderSlate = Color(0xffE2E8F0);
  static const Color _inkPrimary = Color(0xff0F172A);
  static const Color _inkSecondary = Color(0xff475569);
  static const Color _inkMuted = Color(0xff64748B);
  static const Color _cobaltAccent = Color(0xff2563EB);

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(4, (_) => GlobalKey());
  String _selectedSkillCat = skillCategories.first;

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

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioRepository.instance;
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final profile = repo.profile;
        final size = MediaQuery.of(context).size;
        final useSplitScreen = size.width >= 900 && size.height >= 480;

        return Theme(
          data: ThemeData.light().copyWith(
            scaffoldBackgroundColor: _bgPaper,
            colorScheme: const ColorScheme.light(
              primary: _cobaltAccent,
              surface: _cardWhite,
            ),
          ),
          child: Scaffold(
            backgroundColor: _bgPaper,
            floatingActionButton: BackToTopButton(
              scrollController: _scrollController,
            ),
            body: SafeArea(
              child: useSplitScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sticky Left Executive Profile Sidebar
                        Container(
                          width: 340,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            color: _cardWhite,
                            border: Border(
                              right: BorderSide(color: _borderSlate, width: 1),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(28),
                            child: _buildExecutiveProfileSidebar(
                              profile,
                              showNavLinks: true,
                            ),
                          ),
                        ),
                        // Right Scrollable Editorial Magazine Stream
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 40,
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 860),
                              child: _buildEditorialContentStream(
                                repo,
                                profile,
                                isMobile: false,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Mobile / Compact Top Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: _cardWhite,
                            border: Border(
                              bottom: BorderSide(color: _borderSlate),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  profile.fullName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: _inkPrimary,
                                  ),
                                ),
                              ),
                              const TemplateSwitcherButton(
                                isLightMode: true,
                                compact: true,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: _cardWhite,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: _borderSlate),
                                  ),
                                  child: _buildExecutiveProfileSidebar(
                                    profile,
                                    showNavLinks: false,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                _buildEditorialContentStream(
                                  repo,
                                  profile,
                                  isMobile: true,
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
      },
    );
  }

  Widget _buildExecutiveProfileSidebar(
    ProfileData profile, {
    required bool showNavLinks,
  }) {
    const navLabels = [
      '01 / Experience & Education',
      '02 / Capabilities & Stack',
      '03 / Selected Projects',
      '04 / Get In Touch',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showNavLinks) ...[
          const TemplateSwitcherButton(isLightMode: true),
          const SizedBox(height: 24),
        ],
        Row(
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _cobaltAccent, width: 2),
              ),
              child: ClipOval(
                child: PortfolioImage(
                  imagePath: profile.avatarImage,
                  width: 78,
                  height: 78,
                  fit: BoxFit.cover,
                  forLightSurface: true,
                  fallbackIcon: Icons.person_rounded,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: _inkPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.roleTitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _cobaltAccent,
                    ),
                  ),
                  if (profile.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: _inkMuted,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            profile.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _inkMuted,
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
        const SizedBox(height: 16),
        if (profile.isAvailable && profile.availabilityText.trim().isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffECFDF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffA7F3D0)),
            ),
            child: Text(
              "● ${profile.availabilityText}",
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xff047857),
              ),
            ),
          ),
        Text(
          profile.bio,
          style: const TextStyle(
            fontSize: 13.5,
            color: _inkSecondary,
            height: 1.6,
          ),
        ),
        if (profile.stats.isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: _bgPaper,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderSlate),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceAround,
              children: [
                for (final stat in profile.stats)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stat.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: _cobaltAccent,
                        ),
                      ),
                      Text(
                        stat.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: _inkMuted,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
        if (showNavLinks) ...[
          const SizedBox(height: 24),
          const Divider(color: _borderSlate),
          const SizedBox(height: 12),
          for (int i = 0; i < navLabels.length; i++)
            InkWell(
              onTap: () => _scrollTo(i),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        navLabels[i],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _inkPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: _inkMuted,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildEditorialContentStream(
    PortfolioRepository repo,
    ProfileData profile, {
    required bool isMobile,
  }) {
    final skills = _selectedSkillCat == "All Tools"
        ? repo.skills
        : repo.skills
            .where((s) =>
                s.category.toLowerCase() == _selectedSkillCat.toLowerCase())
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 01 / EXPERIENCE & EDUCATION
        SizedBox(key: _sectionKeys[0]),
        _buildSectionHeading("01", "EXPERIENCE & EDUCATION"),
        const SizedBox(height: 18),
        for (final exp in repo.experiences)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderSlate),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      exp.role,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _inkPrimary,
                      ),
                    ),
                    Text(
                      exp.period,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _cobaltAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  exp.company,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _inkSecondary,
                  ),
                ),
                if (exp.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    exp.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: _inkSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        for (final edu in repo.educations)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderSlate),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu.period,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _cobaltAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  edu.degree,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _inkPrimary,
                  ),
                ),
                Text(
                  edu.institution,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _inkSecondary,
                  ),
                ),
                if (edu.honors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Honors: ${edu.honors}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff047857),
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 36),

        // 02 / CAPABILITIES & TECH STACK
        SizedBox(key: _sectionKeys[1]),
        _buildSectionHeading("02", "CAPABILITIES & TECH STACK"),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final plat in repo.platforms)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderSlate),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PortfolioImage(
                      imagePath: plat.img,
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                      forLightSurface: true,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      plat.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _inkPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final cat in skillCategories)
              ChoiceChip(
                label: Text(cat),
                selected: _selectedSkillCat == cat,
                onSelected: (_) => setState(() => _selectedSkillCat = cat),
                selectedColor: _cobaltAccent,
                backgroundColor: _cardWhite,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _selectedSkillCat == cat ? Colors.white : _inkPrimary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final s in skills)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _cardWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderSlate),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PortfolioImage(
                      imagePath: s.img,
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                      forLightSurface: true,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _inkPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 36),

        // 03 / SELECTED PROJECTS
        SizedBox(key: _sectionKeys[2]),
        _buildSectionHeading("03", "SELECTED WORK & HOBBY PROJECTS"),
        const SizedBox(height: 18),
        for (final proj in [...repo.workProjects, ...repo.hobbyProjects])
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderSlate),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showMinimalProjectDetailDialog(proj),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: PortfolioImage(
                                imagePath: proj.image,
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                                forLightSurface: true,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _buildMinimalProjectInfo(proj),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: PortfolioImage(
                                imagePath: proj.image,
                                width: 180,
                                height: 125,
                                fit: BoxFit.cover,
                                forLightSurface: true,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(child: _buildMinimalProjectInfo(proj)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 36),

        // 04 / GET IN TOUCH
        SizedBox(key: _sectionKeys[3]),
        _buildSectionHeading("04", "GET IN TOUCH"),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderSlate),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (profile.email.isNotEmpty)
                      ActionChip(
                        backgroundColor: _bgPaper,
                        label: Text(
                          profile.email,
                          style: const TextStyle(color: _inkPrimary),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: profile.email));
                        },
                      ),
                    if (profile.phone.isNotEmpty)
                      ActionChip(
                        backgroundColor: _bgPaper,
                        label: Text(
                          profile.phone,
                          style: const TextStyle(color: _inkPrimary),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: profile.phone));
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: _inkPrimary),
                  decoration: InputDecoration(
                    labelText: "Your Name",
                    filled: true,
                    fillColor: _bgPaper,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "Enter your name" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  style: const TextStyle(color: _inkPrimary),
                  decoration: InputDecoration(
                    labelText: "Your Email",
                    filled: true,
                    fillColor: _bgPaper,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(color: _inkPrimary),
                  decoration: InputDecoration(
                    labelText: "Your Message",
                    filled: true,
                    fillColor: _bgPaper,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "Enter a message" : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                      backgroundColor: _cobaltAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Send Message",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Divider(color: _borderSlate),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                profile.footerText,
                style: const TextStyle(color: _inkMuted, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "© ${DateTime.now().year} ${profile.fullName}",
                    style: const TextStyle(color: _inkMuted, fontSize: 12),
                  ),
                  const Text("•", style: TextStyle(color: _inkMuted)),
                  const SecretVersionTrigger(
                    versionText: "Version ${PortfolioRepository.appVersion}",
                    textStyle: TextStyle(
                      color: _inkMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSectionHeading(String numStr, String title) {
    return Row(
      children: [
        Text(
          numStr,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: _cobaltAccent,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: _inkPrimary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Divider(color: _borderSlate)),
      ],
    );
  }

  Widget _buildMinimalProjectInfo(ProjectUtils proj) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                proj.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _inkPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _bgPaper,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _borderSlate),
              ),
              child: Text(
                proj.category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _cobaltAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          proj.detail.isNotEmpty ? proj.detail : proj.subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13.5,
            color: _inkSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final t in proj.techStack)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xffEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  t,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _cobaltAccent,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (proj.githubLink != null)
              TextButton.icon(
                onPressed: () => _openUrl(proj.githubLink),
                icon: const Icon(Icons.code_rounded, size: 15),
                label: const Text("GitHub"),
              ),
            if (proj.webLink != null)
              TextButton.icon(
                onPressed: () => _openUrl(proj.webLink),
                icon: const Icon(Icons.open_in_new_rounded, size: 15),
                label: const Text("Live Web"),
              ),
            if (proj.androidLink != null)
              TextButton.icon(
                onPressed: () => _openUrl(proj.androidLink),
                icon: const Icon(Icons.android_rounded, size: 15),
                label: const Text("Android"),
              ),
            if (proj.iosLink != null)
              TextButton.icon(
                onPressed: () => _openUrl(proj.iosLink),
                icon: const Icon(Icons.apple_rounded, size: 15),
                label: const Text("iOS"),
              ),
            TextButton.icon(
              onPressed: () => _showMinimalProjectDetailDialog(proj),
              icon: const Icon(
                Icons.menu_book_rounded,
                size: 15,
                color: _cobaltAccent,
              ),
              label: const Text(
                "Read Details",
                style: TextStyle(
                  color: _cobaltAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMinimalProjectDetailDialog(ProjectUtils proj) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = (screenHeight * 0.28).clamp(140.0, 225.0);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _cardWhite,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: _borderSlate, width: 1.2),
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
                          top: Radius.circular(21),
                        ),
                        child: PortfolioImage(
                          imagePath: proj.image,
                          width: double.infinity,
                          height: bannerHeight,
                          fit: BoxFit.cover,
                          forLightSurface: true,
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
                              color: _inkPrimary.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              proj.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Colors.white,
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
                                _inkPrimary.withValues(alpha: 0.85),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PROJECT CASE STUDY",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                            color: _cobaltAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proj.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _inkPrimary,
                          ),
                        ),
                        if (proj.subtitle.trim().isNotEmpty &&
                            proj.subtitle.trim() != proj.detail.trim()) ...[
                          const SizedBox(height: 6),
                          Text(
                            proj.subtitle,
                            style: const TextStyle(
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
                                    color: const Color(0xffEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          _cobaltAccent.withValues(alpha: 0.28),
                                    ),
                                  ),
                                  child: Text(
                                    tech,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _cobaltAccent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 18),
                        const Text(
                          "CASE STUDY OVERVIEW",
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
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: _inkSecondary,
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Divider(color: _borderSlate),
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
                                  foregroundColor: _inkPrimary,
                                  side: const BorderSide(color: _borderSlate),
                                ),
                                icon: const Icon(Icons.code_rounded, size: 16),
                                label: const Text("View on GitHub"),
                              ),
                            if (proj.webLink != null)
                              ElevatedButton.icon(
                                onPressed: () => _openUrl(proj.webLink),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _cobaltAccent,
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
                                  foregroundColor: _inkPrimary,
                                  side: const BorderSide(color: _borderSlate),
                                ),
                                icon:
                                    const Icon(Icons.android_rounded, size: 16),
                                label: const Text("Android App"),
                              ),
                            if (proj.iosLink != null)
                              OutlinedButton.icon(
                                onPressed: () => _openUrl(proj.iosLink),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _inkPrimary,
                                  side: const BorderSide(color: _borderSlate),
                                ),
                                icon: const Icon(Icons.apple_rounded, size: 16),
                                label: const Text("iOS App"),
                              ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text(
                                "Close",
                                style: TextStyle(
                                  color: _cobaltAccent,
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
}
