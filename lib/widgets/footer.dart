import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: double.maxFinite,
      alignment: Alignment.center,
      child: const Text(
        "Made by Min Naing Paing Oo with Flutter",
        style: TextStyle(
          color: CustomColor.whiteSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400
        ),
      ),
    );
  }
}