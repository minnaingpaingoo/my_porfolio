import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/skill_items.dart';

class SkillsMobile extends StatelessWidget {
  const SkillsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: [
          //platforms
          for(int i=0; i<platformItems.length; i++)
            Container(
              margin: const EdgeInsets.only(right: 10, bottom: 10),
              decoration: BoxDecoration(
                color: CustomColor.bgLight2,
                borderRadius: BorderRadius.circular(5),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                leading: Image.asset(
                  platformItems[i]["img"],
                  width: 26,
                ),
                title: Text(
                  platformItems[i]["title"],
                ),
              ),
            ),
            const SizedBox(height: 50,),
          
          //skills
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for(int i=0; i<skillItems.length; i++)
                Chip(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  label: Text(
                    skillItems[i]["title"],
                  ),
                  avatar: Image.asset(
                    skillItems[i]["img"],
                  ),
                  backgroundColor: CustomColor.bgLight2,
                ),
            ],
          ),
      
        ],
      ),
    );
  }
}