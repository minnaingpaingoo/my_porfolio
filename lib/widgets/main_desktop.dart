import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';

class MainDesktop extends StatelessWidget {
  final VoidCallback onGetInTouch;
  const MainDesktop({super.key, required this.onGetInTouch});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      height: screenHeight / 1.2,
      constraints: const BoxConstraints(
        minHeight: 350.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //intro message
              const Text(
                "Hello,\nI'm Naing Paing Oo\nA Flutter Developer",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: CustomColor.whitePrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 15,),
              //contact btn
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: onGetInTouch,
                  child: const Text(
                    "Get In Touch"
                  ),
                ),
              ),
            ],
          ),
          // Circular image
          CircleAvatar(
            radius: screenWidth / 6, // half of width for circle
            backgroundImage: const AssetImage("assets/my_passport.png"),
            backgroundColor: Colors.transparent,
          ),
        ],
      )
    );
  }
}