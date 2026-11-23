import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/widgets/admin_passcode_dialog.dart';

class Footer extends StatelessWidget {
  const Footer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioRepository.instance;
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final profile = repo.profile;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: CustomColor.scaffoldBg,
            border: Border(
              top: BorderSide(color: CustomColor.cardBorder, width: 1),
            ),
          ),
          child: Column(
            children: [
              if (profile.footerText.trim().isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_stories_outlined,
                      size: 16,
                      color: CustomColor.yellowSecondary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        profile.footerText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CustomColor.whiteSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              Wrap(
                spacing: 14,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "© ${DateTime.now().year} ${profile.fullName} · All Chapters Reserved",
                    style: const TextStyle(
                      color: CustomColor.hintDark,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    "•",
                    style: TextStyle(
                      color: CustomColor.hintDark,
                      fontSize: 12,
                    ),
                  ),
                  const SecretVersionTrigger(
                    versionText: "Version ${PortfolioRepository.appVersion}",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
