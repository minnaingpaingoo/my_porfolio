import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';

class AboutMe extends StatelessWidget {
  final bool isDesktop;

  const AboutMe({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Work Experiences
        Text(
          "Work Experiences",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CustomColor.whitePrimary,
          ),
        ),
        SizedBox(height: 20),
        // Add your work experiences here
        Text(
          "1. Junior Flutter Developer\n ITVisionHub.\n August 2024 – Present",
          style: TextStyle(
            fontSize: 16,
            color: CustomColor.whitePrimary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "2. Junior Developer Intern\n Myanmar DCR Co., Ltd.\n May 2024 – July 2024",
          style: TextStyle(
            fontSize: 16,
            color: CustomColor.whitePrimary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "3. Member\n Collaboration of Kyaik Htee Yoe Pagoda Gorpaga and University of Computer Studies, Thaton\n November 2023 – December 2023",
          style: TextStyle(
            fontSize: 16,
            color: CustomColor.whitePrimary,
          ),
        ),

        SizedBox(height: 40),
        
        // Education
        Text(
          "Education",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CustomColor.whitePrimary,
          ),
        ),
        SizedBox(height: 20),
        // Add your education details here
        Text(
          "• Bachelor of Computer Science (B.C.Sc.)\n• University of Computer Studies, Thaton\n• December, 2017 - January, 2025\n• Passed with 5 Distinctions and Qualified to Proceed to M.C.Sc.\n• Relevant Coursework: Mobile App Development, Web Application Development, Database Management Systems, Software Engineering",
          style: TextStyle(
            fontSize: 16,
            color: CustomColor.whitePrimary,
          ),
        ),
      ],
    );
  }
}