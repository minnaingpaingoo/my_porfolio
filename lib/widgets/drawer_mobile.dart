import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/nav_items.dart';
import 'package:my_porfolio/widgets/admin_passcode_dialog.dart';

class DrawerMobile extends StatelessWidget {
  const DrawerMobile({
    super.key,
    required this.onNavItemTap,
    this.activeNavIndex = 0,
  });

  final Function(int) onNavItemTap;
  final int activeNavIndex;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CustomColor.scaffoldBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: CustomColor.yellowPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "TABLE OF CHAPTERS",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: CustomColor.yellowSecondary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: CustomColor.whiteSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: CustomColor.cardBorder, height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (int i = 0; i < navTitles.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: activeNavIndex == i
                            ? CustomColor.yellowPrimary.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: activeNavIndex == i
                              ? CustomColor.yellowPrimary
                                  .withValues(alpha: 0.45)
                              : Colors.transparent,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () => onNavItemTap(i),
                          leading: Icon(
                            navIcons[i],
                            color: activeNavIndex == i
                                ? CustomColor.yellowSecondary
                                : CustomColor.whiteSecondary,
                          ),
                          title: Text(
                            navTitles[i],
                            style: TextStyle(
                              color: activeNavIndex == i
                                  ? CustomColor.yellowSecondary
                                  : CustomColor.whitePrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            navSubtitles[i],
                            style: const TextStyle(
                              color: CustomColor.hintDark,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(color: CustomColor.cardBorder, height: 1),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: SecretVersionTrigger(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
