import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/utils/project_utils.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import

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
      height: 350,
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
                    onTap:() async {
                        if (project.androidLink != null && await canLaunchUrl(Uri.parse(project.androidLink!))) {
                        await launchUrl(Uri.parse(project.androidLink!));
                        }
                    },
                    child: Image.asset("assets/android_icon.png", width: 19),
                  ),
                if(project.iosLink != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap:() async {
                        if (project.iosLink != null && await canLaunchUrl(Uri.parse(project.iosLink!))) {
                          await launchUrl(Uri.parse(project.iosLink!));
                        }
                      },
                      child: Image.asset("assets/ios.png", width: 19),
                    ),
                  ),
                if(project.webLink != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap:() async {
                        if (project.webLink != null && await canLaunchUrl(Uri.parse(project.webLink!))) {
                          await launchUrl(Uri.parse(project.webLink!));
                        }
                      },
                      child: Image.asset("assets/web.png", width: 19),
                    ),
                  ),
                if(project.githubLink != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap:() async {
                        if (project.githubLink != null && await canLaunchUrl(Uri.parse(project.githubLink!))) {
                          await launchUrl(Uri.parse(project.githubLink!));
                        }
                      }, 
                      child: Image.asset("assets/github.png", width: 19),
                    ),
                  ),
                const SizedBox(width: 6),
                OverflowBar(
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(project.title),
                              content: Text(project.detail),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        "Read Details",
                        style: TextStyle(
                          color: CustomColor.whitePrimary,
                          fontSize: 10,
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
