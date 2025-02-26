import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/skill_items.dart';

class SkillsDesktop extends StatelessWidget {
  const SkillsDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //platforms
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
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
                      //height: 26,
                    ),
                    title: Text(
                      platformItems[i]["title"],
                      style: const TextStyle(
                        color: CustomColor.whitePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 50,),
        //skills
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for(int i=0; i<skillItems.length; i++)
                  Chip(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          ),
        ),
      ],
    );
  }
}