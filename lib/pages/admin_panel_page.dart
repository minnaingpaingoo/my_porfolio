import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/skill_items.dart';
import 'package:my_porfolio/models/portfolio_models.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/utils/project_utils.dart';
import 'package:my_porfolio/widgets/cloudinary_image_picker_field.dart';
import 'package:my_porfolio/widgets/custom_textfield.dart';
import 'package:my_porfolio/widgets/portfolio_image.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int _selectedTabIndex = 0;

  // Login controllers
  final _passkeyController = TextEditingController();
  final _emailAuthController = TextEditingController();
  final _passwordAuthController = TextEditingController();
  bool _useFirebaseEmailLogin = false;
  bool _isAuthLoading = false;
  String? _authError;

  static const List<_AdminNavSection> _sections = [
    _AdminNavSection(
      title: "Overview & Cloud Sync",
      subtitle: "Firestore status & 1-click seed",
      icon: Icons.cloud_sync_rounded,
    ),
    _AdminNavSection(
      title: "Prologue & Profile",
      subtitle: "Hero bio, stats & social links",
      icon: Icons.badge_outlined,
    ),
    _AdminNavSection(
      title: "Chapter I · Journey",
      subtitle: "Work experiences & education",
      icon: Icons.timeline_rounded,
    ),
    _AdminNavSection(
      title: "Chapter II · Arsenal",
      subtitle: "Platforms & technical skills",
      icon: Icons.handyman_outlined,
    ),
    _AdminNavSection(
      title: "Chapters III & IV · Projects",
      subtitle: "Work & hobby case studies",
      icon: Icons.collections_bookmark_outlined,
    ),
    _AdminNavSection(
      title: "Epilogue · Messages Inbox",
      subtitle: "Visitor inquiries from contact form",
      icon: Icons.mark_email_unread_outlined,
    ),
  ];

  @override
  void dispose() {
    _passkeyController.dispose();
    _emailAuthController.dispose();
    _passwordAuthController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CustomColor.bgLight2,
        content: Text(
          message,
          style: const TextStyle(color: CustomColor.whitePrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioRepository.instance;
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        final isWide = size.width >= 900 && size.height >= 480;
        final isCompactAppBar = size.width < 540;
        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            repo.signOutAdmin();
          },
          child: Scaffold(
            backgroundColor: CustomColor.scaffoldBg,
            appBar: AppBar(
              backgroundColor: CustomColor.bgLight1,
              elevation: 0,
              leading: IconButton(
                tooltip: "Back to Storybook (Clear Session)",
                onPressed: () async {
                  await repo.signOutAdmin();
                  if (context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: CustomColor.whitePrimary,
                ),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    color: CustomColor.yellowPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isCompactAppBar
                          ? "Developer's Desk"
                          : "The Developer's Desk · Storybook Admin CMS",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isCompactAppBar ? 15.5 : 17,
                        fontWeight: FontWeight.w800,
                        color: CustomColor.whitePrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompactAppBar ? 8 : 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: repo.isFirebaseAvailable
                          ? CustomColor.emeraldAccent.withValues(alpha: 0.15)
                          : CustomColor.yellowPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: repo.isFirebaseAvailable
                            ? CustomColor.emeraldAccent
                            : CustomColor.yellowPrimary,
                      ),
                    ),
                    child: Text(
                      repo.isFirebaseAvailable
                          ? (isCompactAppBar ? "Live" : "Firestore Connected")
                          : "Local",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: repo.isFirebaseAvailable
                            ? CustomColor.emeraldAccent
                            : CustomColor.yellowSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                if (repo.isAdminAuthenticated)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton.icon(
                      onPressed: () async {
                        await repo.signOutAdmin();
                        if (context.mounted) {
                          Navigator.of(context).maybePop();
                        }
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 17,
                        color: CustomColor.crimsonAccent,
                      ),
                      label: Text(
                        isCompactAppBar ? "Lock" : "Lock Desk",
                        style: const TextStyle(
                          color: CustomColor.crimsonAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: !repo.isAdminAuthenticated
                  ? _buildAuthGate(repo)
                  : isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSidebar(repo),
                            const VerticalDivider(
                              width: 1,
                              color: CustomColor.cardBorder,
                            ),
                            Expanded(
                              child: _buildActiveSectionContent(repo),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildMobileTabStrip(repo),
                            const Divider(
                                height: 1, color: CustomColor.cardBorder),
                            Expanded(
                              child: _buildActiveSectionContent(repo),
                            ),
                          ],
                        ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // AUTHENTICATION GATE
  // ===========================================================================

  Widget _buildAuthGate(PortfolioRepository repo) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: kStoryCardDecoration(
              isHighlighted: true,
              backgroundColor: CustomColor.bgLight1,
              borderRadius: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CustomColor.yellowPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: CustomColor.yellowSecondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DEVELOPER AUTHENTICATION",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: CustomColor.yellowSecondary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Unlock The Developer's Desk",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: CustomColor.whitePrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  "Sign in to dynamically insert, edit, or reorder your Storybook chapters, projects, skills, and timeline milestones.",
                  style: TextStyle(
                    fontSize: 13.5,
                    color: CustomColor.whiteSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Mode Switcher: Passkey vs Firebase Email/Password
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Developer Passkey"),
                        selected: !_useFirebaseEmailLogin,
                        onSelected: (_) {
                          setState(() {
                            _useFirebaseEmailLogin = false;
                            _authError = null;
                          });
                        },
                        selectedColor: CustomColor.yellowPrimary,
                        backgroundColor: CustomColor.bgLight2,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: !_useFirebaseEmailLogin
                              ? CustomColor.scaffoldBg
                              : CustomColor.whiteSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Firebase Auth"),
                        selected: _useFirebaseEmailLogin,
                        onSelected: (_) {
                          setState(() {
                            _useFirebaseEmailLogin = true;
                            _authError = null;
                          });
                        },
                        selectedColor: CustomColor.yellowPrimary,
                        backgroundColor: CustomColor.bgLight2,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _useFirebaseEmailLogin
                              ? CustomColor.scaffoldBg
                              : CustomColor.whiteSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!_useFirebaseEmailLogin) ...[
                  CustomTextfield(
                    controller: _passkeyController,
                    hintText: "Enter Passcode",
                    labelText: "Admin Passcode",
                    prefixIcon: Icons.key_rounded,
                    keyboardType: TextInputType.number,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final ok = repo.signInWithPasskey(
                          _passkeyController.text,
                        );
                        if (!ok) {
                          setState(() {
                            _authError =
                                "Invalid passcode. Please try again.";
                          });
                        } else {
                          _showToast("Welcome to the Developer's Desk!");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.yellowPrimary,
                        foregroundColor: CustomColor.scaffoldBg,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.lock_open_rounded, size: 18),
                      label: const Text(
                        "Unlock Developer's Desk",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ] else ...[
                  CustomTextfield(
                    controller: _emailAuthController,
                    hintText: "naingpaingoo@gmail.com",
                    labelText: "Admin Email",
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 14),
                  CustomTextfield(
                    controller: _passwordAuthController,
                    hintText: "Enter Firebase Auth Password",
                    labelText: "Password",
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAuthLoading
                          ? null
                          : () async {
                              setState(() {
                                _isAuthLoading = true;
                                _authError = null;
                              });
                              final err = await repo.signInWithEmailPassword(
                                _emailAuthController.text,
                                _passwordAuthController.text,
                              );
                              if (!mounted) return;
                              setState(() {
                                _isAuthLoading = false;
                                _authError = err;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.yellowPrimary,
                        foregroundColor: CustomColor.scaffoldBg,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text(
                        "Sign In",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
                if (_authError != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _authError!,
                    style: const TextStyle(
                      color: CustomColor.crimsonAccent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SIDEBAR & MOBILE TABS
  // ===========================================================================

  Widget _buildSidebar(PortfolioRepository repo) {
    return Container(
      width: 280,
      color: CustomColor.bgLight1,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              "STORYBOOK CHAPTERS CMS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: CustomColor.hintDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final sec = _sections[index];
                final isSelected = _selectedTabIndex == index;
                final showBadge =
                    index == 5 && repo.unreadMessageCount > 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CustomColor.yellowPrimary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? CustomColor.yellowPrimary.withValues(alpha: 0.55)
                          : Colors.transparent,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      onTap: () => setState(() => _selectedTabIndex = index),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: Icon(
                        sec.icon,
                        color: isSelected
                            ? CustomColor.yellowSecondary
                            : CustomColor.whiteSecondary,
                      ),
                      title: Text(
                        sec.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? CustomColor.yellowSecondary
                              : CustomColor.whitePrimary,
                        ),
                      ),
                      subtitle: Text(
                        sec.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: CustomColor.hintDark,
                        ),
                      ),
                      trailing: showBadge
                          ? CircleAvatar(
                              radius: 10,
                              backgroundColor: CustomColor.crimsonAccent,
                              child: Text(
                                "${repo.unreadMessageCount}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTabStrip(PortfolioRepository repo) {
    return Container(
      color: CustomColor.bgLight1,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < _sections.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_sections[i].title),
                  selected: _selectedTabIndex == i,
                  onSelected: (_) => setState(() => _selectedTabIndex = i),
                  selectedColor: CustomColor.yellowPrimary,
                  backgroundColor: CustomColor.bgLight2,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _selectedTabIndex == i
                        ? CustomColor.scaffoldBg
                        : CustomColor.whiteSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSectionContent(PortfolioRepository repo) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewSection(repo);
      case 1:
        return _ProfileEditorTab(
          repo: repo,
          onSaved: _showToast,
        );
      case 2:
        return _JourneyManagerTab(
          repo: repo,
          onSaved: _showToast,
        );
      case 3:
        return _ArsenalManagerTab(
          repo: repo,
          onSaved: _showToast,
        );
      case 4:
        return _ProjectsManagerTab(
          repo: repo,
          onSaved: _showToast,
        );
      case 5:
        return _MessagesInboxTab(
          repo: repo,
          onSaved: _showToast,
        );
      default:
        return _buildOverviewSection(repo);
    }
  }

  // ===========================================================================
  // TAB 0: OVERVIEW & CLOUD FIRESTORE SYNC
  // ===========================================================================

  Widget _buildOverviewSection(PortfolioRepository repo) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "STORYBOOK CONTROL CENTER",
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: CustomColor.yellowSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Overview & Cloud Firestore Sync",
            style: TextStyle(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.w900,
              color: CustomColor.whitePrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "All changes made in the Developer's Desk immediately update the live Storybook UI and persist to Cloud Firestore (project: my-portfolio-b1b1c).",
            style: TextStyle(
              fontSize: 14,
              color: CustomColor.whiteSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (repo.lastFirestoreError != null)
            Container(
              width: double.maxFinite,
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: kStoryCardDecoration(
                backgroundColor:
                    CustomColor.crimsonAccent.withValues(alpha: 0.12),
                borderRadius: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: CustomColor.crimsonAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Firestore Permission / Rules Notice (my-portfolio-b1b1c)",
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          const rules = '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}''';
                          await Clipboard.setData(
                            const ClipboardData(text: rules),
                          );
                          _showToast(
                            "Firestore Rules copied! Paste into Firebase Console -> Firestore Database -> Rules -> Publish.",
                          );
                        },
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: CustomColor.yellowSecondary,
                        ),
                        label: const Text(
                          "Copy Firestore Rules",
                          style: TextStyle(
                            color: CustomColor.yellowSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Last Firestore response: ${repo.lastFirestoreError}\n"
                    "To allow the Web Admin Panel to read & write directly to Cloud Firestore, open Firebase Console (my-portfolio-b1b1c) → Firestore Database → Rules, paste the copied rules (also saved in firestore.rules), and click Publish.",
                    style: const TextStyle(
                      fontSize: 13,
                      color: CustomColor.whiteSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          // Summary metric cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricCard(
                label: "Work Projects",
                count: "${repo.workProjects.length}",
                icon: Icons.work_outline_rounded,
                onTap: () => setState(() => _selectedTabIndex = 4),
              ),
              _MetricCard(
                label: "Hobby Projects",
                count: "${repo.hobbyProjects.length}",
                icon: Icons.rocket_launch_outlined,
                onTap: () => setState(() => _selectedTabIndex = 4),
              ),
              _MetricCard(
                label: "Technical Skills",
                count: "${repo.skills.length}",
                icon: Icons.code_rounded,
                onTap: () => setState(() => _selectedTabIndex = 3),
              ),
              _MetricCard(
                label: "Timeline Milestones",
                count: "${repo.experiences.length + repo.educations.length}",
                icon: Icons.timeline_rounded,
                onTap: () => setState(() => _selectedTabIndex = 2),
              ),
              _MetricCard(
                label: "Visitor Messages",
                count: "${repo.messages.length}",
                icon: Icons.mail_outline_rounded,
                onTap: () => setState(() => _selectedTabIndex = 5),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Cloud Sync & Seed Card
          Container(
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            decoration: kStoryCardDecoration(
              backgroundColor: CustomColor.bgLight1,
              borderRadius: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DATABASE SEEDING & SYNCHRONIZATION",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: CustomColor.yellowSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "One-Click Cloud Firestore Seeder",
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.w800,
                    color: CustomColor.whitePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Push all current Storybook chapters (Prologue Profile, Work Experiences, Education, Platforms, Categorized Skills, and Projects) from lib/db/portfolio_db.json directly into Cloud Firestore collections.",
                  style: TextStyle(
                    fontSize: 13.5,
                    color: CustomColor.whiteSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: ElevatedButton.icon(
                        onPressed: repo.isSyncing
                            ? null
                            : () async {
                                final result = await repo.loadFromDbFile(
                                  syncToCloud: true,
                                );
                                _showToast(result);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.yellowPrimary,
                          foregroundColor: CustomColor.scaffoldBg,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.storage_rounded, size: 18),
                        label: Text(
                          repo.isSyncing
                              ? "Syncing DB File..."
                              : isMobile
                                  ? "Load DB File & Sync Firestore"
                                  : "Load from DB File (lib/db/portfolio_db.json) & Sync to Firestore",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: OutlinedButton.icon(
                        onPressed: repo.isSyncing
                            ? null
                            : () async {
                                final result = await repo.seedAllToFirestore();
                                _showToast(result);
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomColor.whitePrimary,
                          side: const BorderSide(color: CustomColor.cardBorder),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                        label: const Text("Sync Current State to Firestore"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Cloudinary Storage Configuration Card (Responsive for Small & Large Screens)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            decoration: kStoryCardDecoration(
              backgroundColor: CustomColor.bgLight1,
              borderRadius: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "CLOUDINARY IMAGE HOSTING",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: CustomColor.yellowSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: repo.cloudinaryConfig.isConfigured
                            ? CustomColor.emeraldAccent.withValues(alpha: 0.15)
                            : CustomColor.yellowPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: repo.cloudinaryConfig.isConfigured
                              ? CustomColor.emeraldAccent
                              : CustomColor.yellowPrimary,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            repo.cloudinaryConfig.isConfigured
                                ? Icons.check_circle_rounded
                                : Icons.info_outline_rounded,
                            size: 13,
                            color: repo.cloudinaryConfig.isConfigured
                                ? CustomColor.emeraldAccent
                                : CustomColor.yellowSecondary,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              repo.cloudinaryConfig.isConfigured
                                  ? "${repo.cloudinaryConfig.cloudName} (${repo.cloudinaryConfig.uploadPreset})"
                                  : "Not Configured Yet",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: repo.cloudinaryConfig.isConfigured
                                    ? CustomColor.emeraldAccent
                                    : CustomColor.yellowSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Cloudinary Upload Preset Configuration",
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.w800,
                    color: CustomColor.whitePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Configure your Cloudinary Cloud Name and Unsigned Upload Preset so every Setup Form (Profile Portrait, Platform Icons, Skill Icons, and Project Covers) can import local image files directly to Cloudinary.",
                  style: TextStyle(
                    fontSize: 13.5,
                    color: CustomColor.whiteSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: isMobile ? double.infinity : null,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final ok = await showCloudinaryConfigDialog(context);
                      if (ok) {
                        _showToast(
                          "Cloudinary configuration saved to Cloud Firestore!",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.bgLight2,
                      foregroundColor: CustomColor.yellowSecondary,
                      side: const BorderSide(color: CustomColor.cardBorder),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.cloud_done_outlined, size: 18),
                    label: Text(
                      isMobile
                          ? "Configure Cloudinary Preset"
                          : "Configure Cloudinary Cloud Name & Upload Preset",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNavSection {
  final String title;
  final String subtitle;
  final IconData icon;

  const _AdminNavSection({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final VoidCallback onTap;

  const _MetricCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 195,
        padding: const EdgeInsets.all(20),
        decoration: kStoryCardDecoration(
          backgroundColor: CustomColor.bgLight1,
          borderRadius: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: CustomColor.yellowSecondary, size: 22),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: CustomColor.whitePrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: CustomColor.whiteSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TAB 1: PROLOGUE & PROFILE EDITOR
// =============================================================================

class _ProfileEditorTab extends StatefulWidget {
  final PortfolioRepository repo;
  final void Function(String) onSaved;

  const _ProfileEditorTab({
    required this.repo,
    required this.onSaved,
  });

  @override
  State<_ProfileEditorTab> createState() => _ProfileEditorTabState();
}

class _ProfileEditorTabState extends State<_ProfileEditorTab> {
  late TextEditingController _fullNameCtrl;
  late TextEditingController _greetingCtrl;
  late TextEditingController _roleTitleCtrl;
  late TextEditingController _storybookSubtitleCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _availabilityCtrl;
  late TextEditingController _avatarCtrl;
  late TextEditingController _resumeCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _footerCtrl;
  late TextEditingController _githubCtrl;
  late TextEditingController _linkedinCtrl;
  late TextEditingController _twitterCtrl;
  late TextEditingController _facebookCtrl;
  late TextEditingController _instagramCtrl;
  late TextEditingController _telegramCtrl;
  final List<TextEditingController> _statValueCtrls = [];
  final List<TextEditingController> _statLabelCtrls = [];
  bool _isAvailable = true;
  bool _isFetchingFirestore = false;

  @override
  void initState() {
    super.initState();
    final p = widget.repo.profile;
    _fullNameCtrl = TextEditingController(text: p.fullName);
    _greetingCtrl = TextEditingController(text: p.greeting);
    _roleTitleCtrl = TextEditingController(text: p.roleTitle);
    _storybookSubtitleCtrl = TextEditingController(text: p.storybookSubtitle);
    _bioCtrl = TextEditingController(text: p.bio);
    _availabilityCtrl = TextEditingController(text: p.availabilityText);
    _avatarCtrl = TextEditingController(text: p.avatarImage);
    _resumeCtrl = TextEditingController(text: p.resumeUrl);
    _emailCtrl = TextEditingController(text: p.email);
    _phoneCtrl = TextEditingController(text: p.phone);
    _locationCtrl = TextEditingController(text: p.location);
    _footerCtrl = TextEditingController(text: p.footerText);
    _githubCtrl = TextEditingController(text: p.snsLinks['github'] ?? '');
    _linkedinCtrl = TextEditingController(text: p.snsLinks['linkedin'] ?? '');
    _twitterCtrl = TextEditingController(text: p.snsLinks['twitter'] ?? '');
    _facebookCtrl = TextEditingController(text: p.snsLinks['facebook'] ?? '');
    _instagramCtrl = TextEditingController(text: p.snsLinks['instagram'] ?? '');
    _telegramCtrl = TextEditingController(text: p.snsLinks['telegram'] ?? '');
    _isAvailable = p.isAvailable;
    _rebuildStatControllers(p.stats);

    // Fetch latest profile from Cloud Firestore first when opening Prologue & Profile
    _loadProfileFromFirestore();
  }

  void _disposeStatControllers() {
    for (final c in _statValueCtrls) {
      c.dispose();
    }
    for (final c in _statLabelCtrls) {
      c.dispose();
    }
    _statValueCtrls.clear();
    _statLabelCtrls.clear();
  }

  void _rebuildStatControllers(List<StatItem> stats) {
    _disposeStatControllers();
    for (final stat in stats) {
      _statValueCtrls.add(TextEditingController(text: stat.value));
      _statLabelCtrls.add(TextEditingController(text: stat.label));
    }
  }

  void _addStatField() {
    setState(() {
      _statValueCtrls.add(TextEditingController());
      _statLabelCtrls.add(TextEditingController());
    });
  }

  void _removeStatField(int index) {
    if (index < 0 || index >= _statValueCtrls.length) return;
    setState(() {
      _statValueCtrls[index].dispose();
      _statLabelCtrls[index].dispose();
      _statValueCtrls.removeAt(index);
      _statLabelCtrls.removeAt(index);
    });
  }

  void _applyProfileToControllers(ProfileData p) {
    _fullNameCtrl.text = p.fullName;
    _greetingCtrl.text = p.greeting;
    _roleTitleCtrl.text = p.roleTitle;
    _storybookSubtitleCtrl.text = p.storybookSubtitle;
    _bioCtrl.text = p.bio;
    _availabilityCtrl.text = p.availabilityText;
    _avatarCtrl.text = p.avatarImage;
    _resumeCtrl.text = p.resumeUrl;
    _emailCtrl.text = p.email;
    _phoneCtrl.text = p.phone;
    _locationCtrl.text = p.location;
    _footerCtrl.text = p.footerText;
    _githubCtrl.text = p.snsLinks['github'] ?? '';
    _linkedinCtrl.text = p.snsLinks['linkedin'] ?? '';
    _twitterCtrl.text = p.snsLinks['twitter'] ?? '';
    _facebookCtrl.text = p.snsLinks['facebook'] ?? '';
    _instagramCtrl.text = p.snsLinks['instagram'] ?? '';
    _telegramCtrl.text = p.snsLinks['telegram'] ?? '';
    _isAvailable = p.isAvailable;
    _rebuildStatControllers(p.stats);
  }

  Future<void> _loadProfileFromFirestore({bool showToast = false}) async {
    setState(() => _isFetchingFirestore = true);
    final p = await widget.repo.fetchProfileFromFirestore();
    await widget.repo.fetchCloudinaryConfigFromFirestore();
    if (!mounted) return;
    setState(() {
      _applyProfileToControllers(p);
      _isFetchingFirestore = false;
    });
    if (showToast) {
      widget.onSaved("Fetched latest Prologue & Profile data from Cloud Firestore!");
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _greetingCtrl.dispose();
    _roleTitleCtrl.dispose();
    _storybookSubtitleCtrl.dispose();
    _bioCtrl.dispose();
    _availabilityCtrl.dispose();
    _avatarCtrl.dispose();
    _resumeCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _footerCtrl.dispose();
    _githubCtrl.dispose();
    _linkedinCtrl.dispose();
    _twitterCtrl.dispose();
    _facebookCtrl.dispose();
    _instagramCtrl.dispose();
    _telegramCtrl.dispose();
    _disposeStatControllers();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final updatedStats = <StatItem>[];
    for (int i = 0; i < _statValueCtrls.length; i++) {
      final val = _statValueCtrls[i].text.trim();
      final lbl = _statLabelCtrls[i].text.trim();
      if (val.isNotEmpty || lbl.isNotEmpty) {
        updatedStats.add(StatItem(value: val, label: lbl));
      }
    }

    final updated = widget.repo.profile.copyWith(
      fullName: _fullNameCtrl.text.trim(),
      greeting: _greetingCtrl.text.trim(),
      roleTitle: _roleTitleCtrl.text.trim(),
      storybookSubtitle: _storybookSubtitleCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      availabilityText: _availabilityCtrl.text.trim(),
      isAvailable: _isAvailable,
      avatarImage: _avatarCtrl.text.trim(),
      resumeUrl: _resumeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      footerText: _footerCtrl.text.trim(),
      stats: updatedStats,
      snsLinks: {
        'github': _githubCtrl.text.trim(),
        'linkedin': _linkedinCtrl.text.trim(),
        'twitter': _twitterCtrl.text.trim(),
        'facebook': _facebookCtrl.text.trim(),
        'instagram': _instagramCtrl.text.trim(),
        'telegram': _telegramCtrl.text.trim(),
      },
    );
    final msg = await widget.repo.updateProfile(updated);
    widget.onSaved(msg);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PROLOGUE & EPILOGUE SETTINGS",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: CustomColor.yellowSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Edit Developer Profile & Social Bookmarks",
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w900,
                          color: CustomColor.whitePrimary,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isFetchingFirestore
                            ? null
                            : () => _loadProfileFromFirestore(showToast: true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomColor.yellowSecondary,
                          side: const BorderSide(color: CustomColor.cardBorder),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                        ),
                        icon: _isFetchingFirestore
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cloud_download_outlined,
                                size: 17),
                        label: Text(
                          _isFetchingFirestore
                              ? "Fetching..."
                              : "Fetch Firestore",
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.yellowPrimary,
                          foregroundColor: CustomColor.scaffoldBg,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                        ),
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text(
                          "Save Changes",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: kStoryCardDecoration(
                backgroundColor: CustomColor.bgLight1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile) ...[
                    CustomTextfield(
                      controller: _greetingCtrl,
                      labelText: "Greeting Lead",
                    ),
                    const SizedBox(height: 12),
                    CustomTextfield(
                      controller: _fullNameCtrl,
                      labelText: "Developer Full Name",
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextfield(
                            controller: _greetingCtrl,
                            labelText: "Greeting Lead",
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: CustomTextfield(
                            controller: _fullNameCtrl,
                            labelText: "Developer Full Name",
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  CustomTextfield(
                    controller: _roleTitleCtrl,
                    labelText: "Primary Role / Headline",
                  ),
                  const SizedBox(height: 14),
                  CustomTextfield(
                    controller: _storybookSubtitleCtrl,
                    labelText: "Storybook Subtitle",
                  ),
                  const SizedBox(height: 14),
                  CustomTextfield(
                    controller: _bioCtrl,
                    maxLine: 3,
                    labelText: "Developer Narrative Bio",
                  ),
                  const SizedBox(height: 14),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: CustomColor.emeraldAccent,
                      title: const Text(
                        "Show 'Available for Opportunities' Status Badge",
                        style: TextStyle(
                          color: CustomColor.whitePrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      value: _isAvailable,
                      onChanged: (v) => setState(() => _isAvailable = v),
                    ),
                  ),
                  CustomTextfield(
                    controller: _availabilityCtrl,
                    labelText: "Availability Badge Text",
                  ),
                  const SizedBox(height: 14),
                  CloudinaryImagePickerField(
                    controller: _avatarCtrl,
                    labelText:
                        "Portrait Image (Import to Cloudinary or URL / Asset Path)",
                    circularPreview: true,
                    previewSize: 72,
                  ),
                  const SizedBox(height: 14),
                  CustomTextfield(
                    controller: _resumeCtrl,
                    labelText: "Profile / Resume URL",
                  ),
                  const SizedBox(height: 14),
                  if (isMobile) ...[
                    CustomTextfield(
                      controller: _emailCtrl,
                      labelText: "Contact Email",
                    ),
                    const SizedBox(height: 12),
                    CustomTextfield(
                      controller: _phoneCtrl,
                      labelText: "Contact Phone",
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextfield(
                            controller: _emailCtrl,
                            labelText: "Contact Email",
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CustomTextfield(
                            controller: _phoneCtrl,
                            labelText: "Contact Phone",
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  CustomTextfield(
                    controller: _locationCtrl,
                    labelText: "Location (e.g. Myanmar)",
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 14),
                  CustomTextfield(
                    controller: _footerCtrl,
                    labelText:
                        "Footer Text (e.g. Made by Min Naing Paing Oo with Flutter)",
                    prefixIcon: Icons.short_text_rounded,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        const Text(
                          "PROLOGUE QUICK STATS (FOOTNOTE RIBBON)",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: CustomColor.yellowSecondary,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _addStatField,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CustomColor.yellowSecondary,
                            side: const BorderSide(
                              color: CustomColor.cardBorder,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text(
                            "Add Stat",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_statValueCtrls.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        "No quick stats configured. Click 'Add Stat' to add items (e.g., 4+ Target Platforms).",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: CustomColor.hintDark,
                        ),
                      ),
                    ),
                  for (int i = 0; i < _statValueCtrls.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextfield(
                              controller: _statValueCtrls[i],
                              labelText: "Value (e.g. 4+)",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 4,
                            child: CustomTextfield(
                              controller: _statLabelCtrls[i],
                              labelText: "Label (e.g. Target Platforms)",
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: "Remove Stat",
                            onPressed: () => _removeStatField(i),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: CustomColor.crimsonAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    "SOCIAL MEDIA BOOKMARK LINKS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: CustomColor.yellowSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextfield(
                    controller: _githubCtrl,
                    labelText: "GitHub URL",
                  ),
                  const SizedBox(height: 12),
                  CustomTextfield(
                    controller: _linkedinCtrl,
                    labelText: "LinkedIn URL",
                  ),
                  const SizedBox(height: 12),
                  CustomTextfield(
                    controller: _twitterCtrl,
                    labelText: "Twitter / X URL",
                  ),
                  const SizedBox(height: 12),
                  CustomTextfield(
                    controller: _telegramCtrl,
                    labelText: "Telegram URL",
                  ),
                  const SizedBox(height: 12),
                  CustomTextfield(
                    controller: _facebookCtrl,
                    labelText: "Facebook URL",
                  ),
                  const SizedBox(height: 12),
                  CustomTextfield(
                    controller: _instagramCtrl,
                    labelText: "Instagram URL",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TAB 2: CHAPTER I — JOURNEY (EXPERIENCES & EDUCATIONS CRUD)
// =============================================================================

class _JourneyManagerTab extends StatelessWidget {
  final PortfolioRepository repo;
  final void Function(String) onSaved;

  const _JourneyManagerTab({
    required this.repo,
    required this.onSaved,
  });

  void _showExperienceDialog(BuildContext context, {ExperienceItem? existing}) {
    final roleCtrl = TextEditingController(text: existing?.role ?? '');
    final companyCtrl = TextEditingController(text: existing?.company ?? '');
    final periodCtrl = TextEditingController(text: existing?.period ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final highlightsCtrl = TextEditingController(
      text: existing?.highlights.join('\n') ?? '',
    );
    final orderCtrl = TextEditingController(
      text: "${existing?.order ?? (repo.experiences.length + 1)}",
    );
    bool isCurrent = existing?.isCurrent ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: CustomColor.bgLight1,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              title: Text(
                existing == null
                    ? "Add Work Experience Milestone"
                    : "Edit Work Experience",
                style: const TextStyle(
                  color: CustomColor.whitePrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: (MediaQuery.of(dialogContext).size.width - 72)
                    .clamp(240.0, 520.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextfield(
                        controller: roleCtrl,
                        labelText: "Job Title / Role",
                      ),
                      const SizedBox(height: 12),
                      CustomTextfield(
                        controller: companyCtrl,
                        labelText: "Company / Organization",
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: CustomTextfield(
                              controller: periodCtrl,
                              labelText: "Period (e.g., Aug 2024 – Present)",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextfield(
                              controller: orderCtrl,
                              labelText: "Order",
                            ),
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            "Mark as Current Role",
                            style: TextStyle(color: CustomColor.whitePrimary),
                          ),
                          value: isCurrent,
                          onChanged: (v) => setDialogState(() => isCurrent = v),
                        ),
                      ),
                      CustomTextfield(
                        controller: descCtrl,
                        maxLine: 2,
                        labelText: "Summary Description",
                      ),
                      const SizedBox(height: 12),
                      CustomTextfield(
                        controller: highlightsCtrl,
                        maxLine: 4,
                        labelText: "Bullet Highlights (one per line)",
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (roleCtrl.text.trim().isEmpty) return;
                    final bullets = highlightsCtrl.text
                        .split('\n')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    final msg = await repo.upsertExperience(
                      ExperienceItem(
                        id: existing?.id ?? '',
                        role: roleCtrl.text.trim(),
                        company: companyCtrl.text.trim(),
                        period: periodCtrl.text.trim(),
                        isCurrent: isCurrent,
                        description: descCtrl.text.trim(),
                        highlights: bullets,
                        order: int.tryParse(orderCtrl.text) ?? 1,
                      ),
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    onSaved(msg);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.yellowPrimary,
                    foregroundColor: CustomColor.scaffoldBg,
                  ),
                  child: const Text("Save Milestone"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEducationDialog(BuildContext context, {EducationItem? existing}) {
    final degreeCtrl = TextEditingController(text: existing?.degree ?? '');
    final instCtrl = TextEditingController(text: existing?.institution ?? '');
    final periodCtrl = TextEditingController(text: existing?.period ?? '');
    final honorsCtrl = TextEditingController(text: existing?.honors ?? '');
    final coursesCtrl = TextEditingController(
      text: existing?.coursework.join(', ') ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: CustomColor.bgLight1,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          title: Text(
            existing == null ? "Add Education" : "Edit Education",
            style: const TextStyle(
              color: CustomColor.whitePrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SizedBox(
            width: (MediaQuery.of(dialogContext).size.width - 72)
                .clamp(240.0, 520.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextfield(
                    controller: degreeCtrl,
                    labelText: "Degree Title",
                  ),
                  const SizedBox(height: 12),
                  CustomTextfield(
                    controller: instCtrl,
                    labelText: "University / Institution",
                  ),
                  const SizedBox(height: 12),
                  CustomTextfield(
                    controller: periodCtrl,
                    labelText: "Period",
                  ),
                  const SizedBox(height: 12),
                  CustomTextfield(
                    controller: honorsCtrl,
                    maxLine: 2,
                    labelText: "Honors / Distinctions Badge",
                  ),
                  const SizedBox(height: 12),
                  CustomTextfield(
                    controller: coursesCtrl,
                    maxLine: 2,
                    labelText: "Coursework Tags (comma-separated)",
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (degreeCtrl.text.trim().isEmpty) return;
                final courses = coursesCtrl.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                final msg = await repo.upsertEducation(
                  EducationItem(
                    id: existing?.id ?? '',
                    degree: degreeCtrl.text.trim(),
                    institution: instCtrl.text.trim(),
                    period: periodCtrl.text.trim(),
                    honors: honorsCtrl.text.trim(),
                    coursework: courses,
                    order: existing?.order ?? 1,
                  ),
                );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                onSaved(msg);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.yellowPrimary,
                foregroundColor: CustomColor.scaffoldBg,
              ),
              child: const Text("Save Education"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Work Experiences Header
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CHAPTER I · ACT I",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: CustomColor.yellowSecondary,
                      ),
                    ),
                    Text(
                      "Work Experience Milestones",
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 22,
                        fontWeight: FontWeight.w900,
                        color: CustomColor.whitePrimary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showExperienceDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.yellowPrimary,
                    foregroundColor: CustomColor.scaffoldBg,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    "Add Experience",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final exp in repo.experiences)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: kStoryCardDecoration(
                backgroundColor: CustomColor.bgLight1,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${exp.order}. ${exp.role} · ${exp.company}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exp.period,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: CustomColor.yellowSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _showExperienceDialog(context, existing: exp),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: CustomColor.yellowSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await repo.deleteExperience(exp.id);
                      onSaved("Removed experience entry.");
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: CustomColor.crimsonAccent,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 36),

          // Education Header
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CHAPTER I · ACT II",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: CustomColor.yellowSecondary,
                      ),
                    ),
                    Text(
                      "Education & Honors",
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 22,
                        fontWeight: FontWeight.w900,
                        color: CustomColor.whitePrimary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showEducationDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.yellowPrimary,
                    foregroundColor: CustomColor.scaffoldBg,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    "Add Education",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final edu in repo.educations)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: kStoryCardDecoration(
                backgroundColor: CustomColor.bgLight1,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          edu.degree,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${edu.institution} (${edu.period})",
                          style: const TextStyle(
                            fontSize: 13,
                            color: CustomColor.whiteSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _showEducationDialog(context, existing: edu),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: CustomColor.yellowSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await repo.deleteEducation(edu.id);
                      onSaved("Removed education entry.");
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: CustomColor.crimsonAccent,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 3: CHAPTER II — ARSENAL (PLATFORMS & SKILLS CRUD)
// =============================================================================

class _ArsenalManagerTab extends StatelessWidget {
  final PortfolioRepository repo;
  final void Function(String) onSaved;

  const _ArsenalManagerTab({
    required this.repo,
    required this.onSaved,
  });

  void _showSkillDialog(BuildContext context, {SkillItem? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final imgCtrl = TextEditingController(text: existing?.img ?? '');
    String selectedCat = existing?.category ?? 'Mobile & Core';
    final categories =
        skillCategories.where((c) => c != 'All Tools').toList();
    if (!categories.contains(selectedCat)) {
      selectedCat = categories.first;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: CustomColor.bgLight1,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              title: Text(
                existing == null ? "Add Technical Skill" : "Edit Technical Skill",
                style: const TextStyle(
                  color: CustomColor.whitePrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: (MediaQuery.of(dialogContext).size.width - 72)
                    .clamp(240.0, 460.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextfield(
                        controller: titleCtrl,
                        labelText:
                            "Skill Title (e.g., Flutter, Riverpod, Next.js)",
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCat,
                        dropdownColor: CustomColor.bgLight2,
                        decoration: InputDecoration(
                          labelText: "Skill Domain Category",
                          filled: true,
                          fillColor: CustomColor.textFieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          for (final c in categories)
                            DropdownMenuItem(value: c, child: Text(c)),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedCat = v);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      CloudinaryImagePickerField(
                        controller: imgCtrl,
                        labelText:
                            "Skill Icon (Import to Cloudinary or URL/Asset)",
                        previewSize: 52,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final msg = await repo.upsertSkill(
                      SkillItem(
                        id: existing?.id ?? '',
                        title: titleCtrl.text.trim(),
                        img: imgCtrl.text.trim(),
                        category: selectedCat,
                        order: existing?.order ?? (repo.skills.length + 1),
                      ),
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    onSaved(msg);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.yellowPrimary,
                    foregroundColor: CustomColor.scaffoldBg,
                  ),
                  child: const Text("Save Skill"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPlatformDialog(BuildContext context, {PlatformItem? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final subtitleCtrl = TextEditingController(text: existing?.subtitle ?? '');
    final imgCtrl = TextEditingController(
      text: existing?.img ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: CustomColor.bgLight1,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              title: Text(
                existing == null ? "Add Platform Realm" : "Edit Platform Realm",
                style: const TextStyle(
                  color: CustomColor.whitePrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: (MediaQuery.of(dialogContext).size.width - 72)
                    .clamp(240.0, 460.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextfield(
                        controller: titleCtrl,
                        labelText: "Platform Title",
                      ),
                      const SizedBox(height: 12),
                      CustomTextfield(
                        controller: subtitleCtrl,
                        maxLine: 2,
                        labelText: "Capability Description",
                      ),
                      const SizedBox(height: 12),
                      CloudinaryImagePickerField(
                        controller: imgCtrl,
                        labelText:
                            "Platform Icon (Import to Cloudinary or URL/Asset)",
                        previewSize: 52,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final msg = await repo.upsertPlatform(
                      PlatformItem(
                        id: existing?.id ?? '',
                        title: titleCtrl.text.trim(),
                        subtitle: subtitleCtrl.text.trim(),
                        img: imgCtrl.text.trim(),
                        order: existing?.order ?? (repo.platforms.length + 1),
                      ),
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    onSaved(msg);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.yellowPrimary,
                    foregroundColor: CustomColor.scaffoldBg,
                  ),
                  child: const Text("Save Platform"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Target Platform Realms",
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 22,
                    fontWeight: FontWeight.w900,
                    color: CustomColor.whitePrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showPlatformDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.yellowPrimary,
                    foregroundColor: CustomColor.scaffoldBg,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    "Add Platform",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final plat in repo.platforms)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: kStoryCardDecoration(
                backgroundColor: CustomColor.bgLight1,
              ),
              child: Row(
                children: [
                  PortfolioImage(
                    imagePath: plat.img,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plat.title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                        if (plat.subtitle.isNotEmpty)
                          Text(
                            plat.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: CustomColor.whiteSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _showPlatformDialog(context, existing: plat),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: CustomColor.yellowSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await repo.deletePlatform(plat.id);
                      onSaved("Platform removed.");
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: CustomColor.crimsonAccent,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Categorized Technical Skills",
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 22,
                    fontWeight: FontWeight.w900,
                    color: CustomColor.whitePrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showSkillDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.yellowPrimary,
                    foregroundColor: CustomColor.scaffoldBg,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    "Add Skill",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final skill in repo.skills)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: kStoryCardDecoration(
                    backgroundColor: CustomColor.bgLight1,
                    borderRadius: 14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PortfolioImage(
                        imagePath: skill.img,
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
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
                      const SizedBox(width: 8),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        onPressed: () =>
                            _showSkillDialog(context, existing: skill),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: CustomColor.whiteSecondary,
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        onPressed: () async {
                          await repo.deleteSkill(skill.id);
                          onSaved("Removed skill ${skill.title}.");
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: CustomColor.crimsonAccent,
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

// =============================================================================
// TAB 4: CHAPTERS III & IV — PROJECTS CRUD MANAGER
// =============================================================================

class _ProjectsManagerTab extends StatelessWidget {
  final PortfolioRepository repo;
  final void Function(String) onSaved;

  const _ProjectsManagerTab({
    required this.repo,
    required this.onSaved,
  });

  void _showProjectDialog(BuildContext context, {ProjectUtils? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final subtitleCtrl = TextEditingController(text: existing?.subtitle ?? '');
    final detailCtrl = TextEditingController(text: existing?.detail ?? '');
    final imgCtrl = TextEditingController(
      text: existing?.image ?? '',
    );
    final techCtrl = TextEditingController(
      text: existing?.techStack.join(', ') ?? '',
    );
    final githubCtrl = TextEditingController(text: existing?.githubLink ?? '');
    final webCtrl = TextEditingController(text: existing?.webLink ?? '');
    final androidCtrl =
        TextEditingController(text: existing?.androidLink ?? '');
    final iosCtrl = TextEditingController(text: existing?.iosLink ?? '');
    final orderCtrl = TextEditingController(
      text: "${existing?.order ?? (repo.allProjects.length + 1)}",
    );
    String projectType = existing?.projectType ?? 'work';
    String category = existing?.category ?? 'Mobile App';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isCompactDialog =
                MediaQuery.of(dialogContext).size.width < 520;
            return AlertDialog(
              backgroundColor: CustomColor.bgLight1,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              title: Text(
                existing == null
                    ? "Add Project Chronicle"
                    : "Edit Project Chronicle",
                style: const TextStyle(
                  color: CustomColor.whitePrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: (MediaQuery.of(dialogContext).size.width - 72)
                    .clamp(240.0, 560.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCompactDialog) ...[
                        DropdownButtonFormField<String>(
                          initialValue: projectType,
                          dropdownColor: CustomColor.bgLight2,
                          decoration: InputDecoration(
                            labelText: "Story Chapter",
                            filled: true,
                            fillColor: CustomColor.textFieldBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'work',
                              child: Text("Chapter III · Work Project"),
                            ),
                            DropdownMenuItem(
                              value: 'hobby',
                              child: Text("Chapter IV · Hobby Project"),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() => projectType = v);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: category,
                          dropdownColor: CustomColor.bgLight2,
                          decoration: InputDecoration(
                            labelText: "Platform Category",
                            filled: true,
                            fillColor: CustomColor.textFieldBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Mobile App',
                              child: Text("Mobile App"),
                            ),
                            DropdownMenuItem(
                              value: 'Web Platform',
                              child: Text("Web Platform"),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() => category = v);
                            }
                          },
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: projectType,
                                dropdownColor: CustomColor.bgLight2,
                                decoration: InputDecoration(
                                  labelText: "Story Chapter",
                                  filled: true,
                                  fillColor: CustomColor.textFieldBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'work',
                                    child: Text("Chapter III · Work Project"),
                                  ),
                                  DropdownMenuItem(
                                    value: 'hobby',
                                    child: Text("Chapter IV · Hobby Project"),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setDialogState(() => projectType = v);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: category,
                                dropdownColor: CustomColor.bgLight2,
                                decoration: InputDecoration(
                                  labelText: "Platform Category",
                                  filled: true,
                                  fillColor: CustomColor.textFieldBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Mobile App',
                                    child: Text("Mobile App"),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Web Platform',
                                    child: Text("Web Platform"),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setDialogState(() => category = v);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: CustomTextfield(
                              controller: titleCtrl,
                              labelText: "Project Title",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextfield(
                              controller: orderCtrl,
                              labelText: "Order",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomTextfield(
                        controller: subtitleCtrl,
                        maxLine: 2,
                        labelText: "Card Subtitle Summary",
                      ),
                      const SizedBox(height: 12),
                      CustomTextfield(
                        controller: detailCtrl,
                        maxLine: 4,
                        labelText: "Full Story Case Study (Read Details Modal)",
                      ),
                      const SizedBox(height: 12),
                      CustomTextfield(
                        controller: techCtrl,
                        labelText: "Tech Stack Tags (comma-separated)",
                      ),
                      const SizedBox(height: 12),
                      CloudinaryImagePickerField(
                        controller: imgCtrl,
                        labelText:
                            "Project Cover Image (Import to Cloudinary or URL/Asset)",
                        previewSize: 64,
                      ),
                      const SizedBox(height: 12),
                      CustomTextfield(
                        controller: githubCtrl,
                        labelText: "GitHub Repository URL (optional)",
                      ),
                      const SizedBox(height: 12),
                      CustomTextfield(
                        controller: webCtrl,
                        labelText: "Live Website URL (optional)",
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextfield(
                              controller: androidCtrl,
                              labelText: "Android Link (optional)",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextfield(
                              controller: iosCtrl,
                              labelText: "iOS Link (optional)",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final techList = techCtrl.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    String? clean(String s) =>
                        s.trim().isEmpty ? null : s.trim();

                    final msg = await repo.upsertProject(
                      ProjectUtils(
                        id: existing?.id ?? '',
                        title: titleCtrl.text.trim(),
                        subtitle: subtitleCtrl.text.trim(),
                        detail: detailCtrl.text.trim(),
                        image: imgCtrl.text.trim(),
                        projectType: projectType,
                        category: category,
                        techStack: techList,
                        githubLink: clean(githubCtrl.text),
                        webLink: clean(webCtrl.text),
                        androidLink: clean(androidCtrl.text),
                        iosLink: clean(iosCtrl.text),
                        order: int.tryParse(orderCtrl.text) ?? 1,
                      ),
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    onSaved(msg);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.yellowPrimary,
                    foregroundColor: CustomColor.scaffoldBg,
                  ),
                  child: const Text("Save Project"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CHAPTERS III & IV · CHRONICLES",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: CustomColor.yellowSecondary,
                      ),
                    ),
                    Text(
                      "Work & Hobby Projects Manager",
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w900,
                        color: CustomColor.whitePrimary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showProjectDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.yellowPrimary,
                    foregroundColor: CustomColor.scaffoldBg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    "Add New Project",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Chapter III · Work Projects",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: CustomColor.yellowSecondary,
            ),
          ),
          const SizedBox(height: 12),
          for (final proj in repo.workProjects)
            _buildProjectAdminRow(context, proj),
          const SizedBox(height: 28),
          const Text(
            "Chapter IV · Hobby Projects",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: CustomColor.yellowSecondary,
            ),
          ),
          const SizedBox(height: 12),
          for (final proj in repo.hobbyProjects)
            _buildProjectAdminRow(context, proj),
        ],
      ),
    );
  }

  Widget _buildProjectAdminRow(BuildContext context, ProjectUtils proj) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: kStoryCardDecoration(
        backgroundColor: CustomColor.bgLight1,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: PortfolioImage(
              imagePath: proj.image,
              width: 72,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proj.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: CustomColor.whitePrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${proj.category} · ${proj.techStack.join(', ')}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CustomColor.yellowSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showProjectDialog(context, existing: proj),
            icon: const Icon(
              Icons.edit_outlined,
              color: CustomColor.yellowSecondary,
            ),
          ),
          IconButton(
            onPressed: () async {
              await repo.deleteProject(proj.id);
              onSaved("Removed project ${proj.title}.");
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: CustomColor.crimsonAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 5: EPILOGUE — VISITOR MESSAGES INBOX
// =============================================================================

class _MessagesInboxTab extends StatelessWidget {
  final PortfolioRepository repo;
  final void Function(String) onSaved;

  const _MessagesInboxTab({
    required this.repo,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final messages = repo.messages;
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "EPILOGUE · DEVELOPER'S INBOX",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: CustomColor.yellowSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Visitor Contact Messages (${messages.length})",
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w900,
              color: CustomColor.whitePrimary,
            ),
          ),
          const SizedBox(height: 20),
          if (messages.isEmpty)
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(36),
              decoration: kStoryCardDecoration(
                backgroundColor: CustomColor.bgLight1,
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 42,
                    color: CustomColor.hintDark,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "No visitor messages received yet.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CustomColor.whitePrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Messages submitted via the Epilogue 'Get In Touch' form appear here automatically.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: CustomColor.whiteSecondary,
                    ),
                  ),
                ],
              ),
            ),
          for (final msg in messages)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: kStoryCardDecoration(
                isHighlighted: !msg.isRead,
                backgroundColor: CustomColor.bgLight1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        msg.isRead
                            ? Icons.drafts_outlined
                            : Icons.mark_email_unread_rounded,
                        color: msg.isRead
                            ? CustomColor.hintDark
                            : CustomColor.yellowSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "${msg.name} <${msg.email}>",
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: CustomColor.whitePrimary,
                          ),
                        ),
                      ),
                      Text(
                        msg.createdAt.toLocal().toString().split('.').first,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CustomColor.hintDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    msg.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CustomColor.whiteSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: msg.email),
                            );
                            onSaved("Copied ${msg.email}");
                          },
                          icon: const Icon(Icons.copy_rounded, size: 15),
                          label: const Text("Copy Email"),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final uri = Uri(
                              scheme: 'mailto',
                              path: msg.email,
                              query:
                                  'subject=Re: Your Message to Naing Paing Oo',
                            );
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          icon: const Icon(Icons.reply_rounded, size: 16),
                          label: const Text("Reply"),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              repo.markMessageRead(msg.id, !msg.isRead),
                          icon: Icon(
                            msg.isRead
                                ? Icons.mark_as_unread_outlined
                                : Icons.done_all_rounded,
                            size: 16,
                          ),
                          label: Text(msg.isRead ? "Mark Unread" : "Mark Read"),
                        ),
                        IconButton(
                          onPressed: () async {
                            await repo.deleteMessage(msg.id);
                            onSaved("Message deleted.");
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: CustomColor.crimsonAccent,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
