import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/pages/admin_panel_page.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/widgets/custom_textfield.dart';

/// Displays the app version number. Tapping it 5 times within a short window
/// reveals the hidden Admin Panel Passcode modal.
class SecretVersionTrigger extends StatefulWidget {
  final String versionText;
  final TextStyle? textStyle;

  const SecretVersionTrigger({
    super.key,
    this.versionText = 'Version ${PortfolioRepository.appVersion}',
    this.textStyle,
  });

  @override
  State<SecretVersionTrigger> createState() => _SecretVersionTriggerState();
}

class _SecretVersionTriggerState extends State<SecretVersionTrigger> {
  static const int _requiredTaps = 5;
  int _tapCount = 0;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handleVersionTap() {
    _resetTimer?.cancel();
    _tapCount++;

    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      showAdminPasscodeDialog(context);
    } else {
      _resetTimer = Timer(const Duration(seconds: 3), () {
        _tapCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleVersionTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          widget.versionText,
          style: widget.textStyle ??
              const TextStyle(
                color: CustomColor.hintDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

Future<void> showAdminPasscodeDialog(BuildContext context) async {
  final repo = PortfolioRepository.instance;

  // Always clear previous session so the passcode dialog is shown every 5 taps
  await repo.signOutAdmin();
  if (!context.mounted) return;

  final passcodeController = TextEditingController();
  String? errorMessage;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          void submitPasscode() {
            final ok = repo.signInWithPasskey(passcodeController.text);
            if (ok) {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminPanelPage()),
              );
            } else {
              setDialogState(() {
                errorMessage = 'Invalid admin passcode. Please try again.';
              });
            }
          }

          return Dialog(
            backgroundColor: CustomColor.bgLight1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: CustomColor.cardBorder, width: 1.2),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CustomColor.yellowPrimary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_person_rounded,
                            color: CustomColor.yellowSecondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "RESTRICTED ACCESS",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: CustomColor.yellowSecondary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Admin Panel Passcode",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: CustomColor.whitePrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: CustomColor.whiteSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Enter developer passcode to unlock the Storybook Admin CMS.",
                      style: TextStyle(
                        fontSize: 13,
                        color: CustomColor.whiteSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    CustomTextfield(
                      controller: passcodeController,
                      hintText: "Enter Passcode",
                      labelText: "Passcode",
                      prefixIcon: Icons.key_rounded,
                      keyboardType: TextInputType.number,
                      isPassword: true,
                      onFieldSubmitted: (_) => submitPasscode(),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: kStoryCardDecoration(
                          backgroundColor: CustomColor.crimsonAccent
                              .withValues(alpha: 0.12),
                          borderRadius: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 16,
                              color: CustomColor.crimsonAccent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: CustomColor.crimsonAccent,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: CustomColor.whiteSecondary),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: submitPasscode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColor.yellowPrimary,
                            foregroundColor: CustomColor.scaffoldBg,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.lock_open_rounded, size: 17),
                          label: const Text(
                            "Unlock Admin",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
