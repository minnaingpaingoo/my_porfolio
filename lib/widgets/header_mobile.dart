import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/styles/style.dart';
import 'package:my_porfolio/widgets/site_logo.dart';
import 'package:my_porfolio/widgets/template_switcher_menu.dart';

class HeaderMobile extends StatelessWidget {
  const HeaderMobile({
    super.key,
    this.onLogoTap,
    this.onMenuTap,
  });

  final VoidCallback? onLogoTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: kHeaderDecoration,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SiteLogo(
                onTap: onLogoTap,
              ),
            ),
          ),
          const TemplateSwitcherButton(compact: true),
          const SizedBox(width: 4),
          IconButton(
            tooltip: "Open Chapters",
            onPressed: onMenuTap,
            icon: const Icon(
              Icons.menu_book_rounded,
              color: CustomColor.whitePrimary,
            ),
          ),
        ],
      ),
    );
  }
}
