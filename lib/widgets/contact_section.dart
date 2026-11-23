import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/size.dart';
import 'package:my_porfolio/models/portfolio_models.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/widgets/custom_textfield.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard(String label, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CustomColor.bgLight2,
        content: Text(
          "$label copied to clipboard: $text",
          style: const TextStyle(color: CustomColor.whitePrimary),
        ),
      ),
    );
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final repo = PortfolioRepository.instance;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    await repo.submitContactMessage(
      name: name,
      email: email,
      message: message,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _nameController.clear();
    _emailController.clear();
    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CustomColor.bgLight2,
        duration: const Duration(seconds: 5),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: CustomColor.emeraldAccent),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Your message was delivered to the Developer's Desk Inbox!",
                style: TextStyle(
                  color: CustomColor.whitePrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: "Also Open Email",
          textColor: CustomColor.yellowSecondary,
          onPressed: () async {
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: repo.profile.email,
              query:
                  'subject=Get In Touch From Portfolio&body=Name: $name\nEmail: $email\n\nMessage: $message',
            );
            if (await canLaunchUrl(emailLaunchUri)) {
              await launchUrl(emailLaunchUri);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = PortfolioRepository.instance.profile;
    final sns = profile.snsLinks;

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 64),
      color: CustomColor.bgLight1,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Column(
            children: [
              const StoryChapterHeader(
                chapterNumber: "Epilogue",
                title: "Get In Touch",
                subtitle:
                    "Ready to start a new chapter together? Send a message directly to the Developer's Desk or connect via social channels.",
              ),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= kMedDesktopWidth;
                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildDeveloperContactCard(profile, sns),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          flex: 6,
                          child: _buildMessageFormCard(constraints.maxWidth),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildMessageFormCard(constraints.maxWidth),
                      const SizedBox(height: 24),
                      _buildDeveloperContactCard(profile, sns),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperContactCard(
    ProfileData profile,
    Map<String, String> sns,
  ) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: kStoryCardDecoration(
        backgroundColor: CustomColor.bgLight2,
        borderRadius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DIRECT CHANNELS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: CustomColor.yellowSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Developer's Dispatch",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: CustomColor.whitePrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Messages sent through the form are stored directly in the Admin Panel Inbox. You can also reach out via email, phone, or social links below.",
            style: TextStyle(
              fontSize: 13.5,
              color: CustomColor.whiteSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          // Email Card
          _DirectChannelTile(
            icon: Icons.email_outlined,
            label: "Email Address",
            value: profile.email,
            onTap: () => _openUrl("mailto:${profile.email}"),
            onCopy: () => _copyToClipboard("Email", profile.email),
          ),
          const SizedBox(height: 12),
          // Phone Card
          _DirectChannelTile(
            icon: Icons.phone_in_talk_outlined,
            label: "Direct Phone",
            value: profile.phone,
            onTap: () => _openUrl("tel:${profile.phone}"),
            onCopy: () => _copyToClipboard("Phone", profile.phone),
          ),
          const SizedBox(height: 24),
          const Divider(color: CustomColor.cardBorder),
          const SizedBox(height: 16),
          const Text(
            "SOCIAL BOOKMARKS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: CustomColor.hintDark,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SocialIconButton(
                assetPath: "assets/github.png",
                tooltip: "GitHub",
                onTap: () => _openUrl(sns['github']),
              ),
              _SocialIconButton(
                assetPath: "assets/linkedin.png",
                tooltip: "LinkedIn",
                onTap: () => _openUrl(sns['linkedin']),
              ),
              _SocialIconButton(
                assetPath: "assets/twitter.png",
                tooltip: "Twitter / X",
                onTap: () => _openUrl(sns['twitter']),
              ),
              _SocialIconButton(
                assetPath: "assets/facebook.png",
                tooltip: "Facebook",
                onTap: () => _openUrl(sns['facebook']),
              ),
              _SocialIconButton(
                assetPath: "assets/ig.png",
                tooltip: "Instagram",
                onTap: () => _openUrl(sns['instagram']),
              ),
              _SocialIconButton(
                assetPath: "assets/telegram.png",
                tooltip: "Telegram",
                onTap: () => _openUrl(sns['telegram']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFormCard(double availableWidth) {
    final isWideForm = availableWidth >= kMinDesktopWidth;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: kStoryCardDecoration(
        backgroundColor: CustomColor.bgLight2,
        borderRadius: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "WRITE A MESSAGE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: CustomColor.yellowSecondary,
              ),
            ),
            const SizedBox(height: 18),
            if (isWideForm)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildNameField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildEmailField()),
                ],
              )
            else ...[
              _buildNameField(),
              const SizedBox(height: 16),
              _buildEmailField(),
            ],
            const SizedBox(height: 16),
            CustomTextfield(
              controller: _messageController,
              maxLine: 6,
              hintText: "Your Message",
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.yellowPrimary,
                  foregroundColor: CustomColor.scaffoldBg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  "Get In Touch",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return CustomTextfield(
      controller: _nameController,
      hintText: "Your Name",
      prefixIcon: Icons.person_outline_rounded,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return CustomTextfield(
      controller: _emailController,
      hintText: "Your Email",
      prefixIcon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}

class _DirectChannelTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  const _DirectChannelTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CustomColor.bgLight1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CustomColor.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: CustomColor.yellowSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CustomColor.hintDark,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: CustomColor.whitePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: "Copy $label",
            onPressed: onCopy,
            icon: const Icon(
              Icons.copy_rounded,
              size: 17,
              color: CustomColor.whiteSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String assetPath;
  final String tooltip;
  final VoidCallback onTap;

  const _SocialIconButton({
    required this.assetPath,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CustomColor.bgLight1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CustomColor.cardBorder),
          ),
          child: Image.asset(
            assetPath,
            width: 24,
            height: 24,
            color: assetPath.toLowerCase().endsWith('github.png')
                ? CustomColor.whitePrimary
                : null,
          ),
        ),
      ),
    );
  }
}
