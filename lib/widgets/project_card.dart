
import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/utils/project_utils.dart';
import 'dart:js' as js;

class ProjectCardWidget extends StatelessWidget {
  const ProjectCardWidget({
    super.key,
    required this.project,
  });

  final ProjectUtils project;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: 290,
      width: 260,
      decoration: BoxDecoration(
        color: CustomColor.bgLight2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Project Image
          Image.asset(
            project.image,
            height: 140, 
            width: 260,
            fit: BoxFit.cover,
          ),
          //Title
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 15, 12, 12),
            child: Text(
              project.title, 
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: CustomColor.whitePrimary,
              ),
            ),
          ),
          //Subtitle
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              project.subtitle, 
              style: const TextStyle(
                fontSize: 12,
                color: CustomColor.whiteSecondary,
              ),
            ),
          ),
          const Spacer(),
          //footer
          Container(
            color: CustomColor.bgLight1,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Github Link
                const Text(
                  "Available On:",
                  style: TextStyle(
                    color: CustomColor.yellowSecondary,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                if(project.androidLink != null)
                  InkWell(
                    onTap:(){
                      js.context.callMethod('open', [project.androidLink]);
                    },
                    child: Image.asset("assets/android_icon.png", width: 19),
                  ),
                if(project.iosLink != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap:(){
                        js.context.callMethod('open', [project.iosLink]);
                      },
                      child: Image.asset("assets/ios.png", width: 19),
                    ),
                  ),
                if(project.webLink != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap:(){
                        js.context.callMethod('open', [project.webLink]);
                      },
                      child: Image.asset("assets/web.png", width: 19),
                    ),
                  ),
                if(project.githubLink != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap:(){
                        js.context.callMethod('open', [project.githubLink]);
                      }, 
                      child: Image.asset("assets/github.png", width: 19),
                    ),
                  ),
                const SizedBox(width: 6),
                OverflowBar(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Read Details",
                        style: TextStyle(
                          color: CustomColor.whitePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
