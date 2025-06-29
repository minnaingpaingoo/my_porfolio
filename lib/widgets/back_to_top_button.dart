import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';

class BackToTopButton extends StatelessWidget {
  final ScrollController scrollController;

  const BackToTopButton({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: FloatingActionButton(
          onPressed: () {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          backgroundColor: CustomColor.yellowPrimary,
          child: const Icon(Icons.arrow_upward, color: CustomColor.whitePrimary),
        ),
      ),
    );
  }
}