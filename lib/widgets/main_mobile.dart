import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';

class MainMobile extends StatelessWidget {
  final VoidCallback onGetInTouch;
  const MainMobile({super.key, required this.onGetInTouch});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return  Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      height: screenHeight,
      constraints: const BoxConstraints(minHeight: 560),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //avatar img
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors:[
                  CustomColor.scaffoldBg.withOpacity(0.6),
                  CustomColor.scaffoldBg.withOpacity(0.6),
                ]
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Image.asset(
              "assets/avatar.png",
              width: screenWidth,
            ),
          ),
          const SizedBox(height: 30),
          //intro message
          const Text(
            "Hello,\nI'm Naing Paing Oo\nA Flutter Developer",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CustomColor.whitePrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15,),
          //contact btn
          SizedBox(
            width: 190,
            child: ElevatedButton(
              onPressed: onGetInTouch,
              child: const Text(
                "Get In Touch"
              ),
            ),
          ),
        ],
      ),
    );
  }
}