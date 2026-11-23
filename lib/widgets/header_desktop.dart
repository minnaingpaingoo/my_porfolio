import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/nav_items.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/widgets/site_logo.dart';

class HeaderDesktop extends StatelessWidget {
  const HeaderDesktop({
    super.key,
    required this.onNavMenuTap,
    this.activeNavIndex = 0,
  });

  final Function(int) onNavMenuTap;
  final int activeNavIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 24,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      width: double.infinity,
      decoration: kHeaderDecoration,
      child: Row(
        children: [
          SiteLogo(
            onTap: () => onNavMenuTap(0),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < navTitles.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => onNavMenuTap(i),
                          borderRadius: BorderRadius.circular(30),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: activeNavIndex == i
                                  ? CustomColor.yellowPrimary
                                      .withValues(alpha: 0.16)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: activeNavIndex == i
                                    ? CustomColor.yellowPrimary
                                        .withValues(alpha: 0.55)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  navIcons[i],
                                  size: 15,
                                  color: activeNavIndex == i
                                      ? CustomColor.yellowSecondary
                                      : CustomColor.whiteSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  navTitles[i],
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: activeNavIndex == i
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: activeNavIndex == i
                                        ? CustomColor.yellowSecondary
                                        : CustomColor.whitePrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
