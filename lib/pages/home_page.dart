import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/size.dart';
import 'package:my_porfolio/widgets/drawer_mobile.dart';
import 'package:my_porfolio/widgets/header_desktop.dart';
import 'package:my_porfolio/widgets/header_mobile.dart';
import 'package:my_porfolio/widgets/main_desktop.dart';
import 'package:my_porfolio/widgets/main_mobile.dart';
import 'package:my_porfolio/widgets/project_section.dart';
import 'package:my_porfolio/widgets/skills_desktop.dart';
import 'package:my_porfolio/widgets/skills_mobile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          key:scaffoldKey,
          backgroundColor: CustomColor.scaffoldBg,
          endDrawer: constraints.maxWidth >= kMinDesktopWidth ? null : const DrawerMobile(),
          body: ListView(
            scrollDirection: Axis.vertical,
            children: [
              //Main
              if(constraints.maxWidth >= kMinDesktopWidth)
                const HeaderDesktop()
              else
                HeaderMobile(
                  onLogoTap: () {},
                  onMenuTap: () {
                    scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
              if(constraints.maxWidth >= kMinDesktopWidth)
                const MainDesktop()
              else
                const MainMobile(),
              
              //SKILLS
              Container(
                width: screenWidth,
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
                color: CustomColor.bgLight1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //title
                    const Text(
                      "What I can do",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CustomColor.whitePrimary,
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    //Platforms and Skills
                    if(constraints.maxWidth >= kMedDesktopWidth)
                      //SkillsDesktop
                      const SkillsDesktop()
                    else
                      //SkillsMobile
                      const SkillsMobile(),  

                  ],
                ),
              ),

              const SizedBox(height: 30,),

              //PROJECTS
              const ProjectSection(),

              //CONTACT
              Container(
                height: 500,
                width: double.maxFinite,
                color: Colors.blueGrey,
              ),

              //FOOTER
              Container(
                height: 500,
                width: double.maxFinite,
              ),
            ],
          ));
      }
    );
  }
}
