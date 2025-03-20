import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/size.dart';
import 'package:my_porfolio/widgets/about_me_section.dart';
import 'package:my_porfolio/widgets/contact_section.dart';
import 'package:my_porfolio/widgets/drawer_mobile.dart';
import 'package:my_porfolio/widgets/footer.dart';
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
  final scrollController = ScrollController();
  final List<GlobalKey> navbarKeys = List.generate(5, (index)=> GlobalKey());
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          key:scaffoldKey,
          backgroundColor: CustomColor.scaffoldBg,
          endDrawer: constraints.maxWidth >= kMinDesktopWidth 
          ? null 
          : DrawerMobile(onNavItemTap: (int navIndex){
            //call funciton
            scaffoldKey.currentState?.closeEndDrawer();
            scrollToSection(navIndex);
          },),
          body: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(key: navbarKeys.first),
                //Main
                if(constraints.maxWidth >= kMinDesktopWidth)
                  HeaderDesktop(onNavMenuTap: (int navIndex){
                    //call function
                    scrollToSection(navIndex);
                  },)
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
                  key: navbarKeys[1],
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
                ProjectSection(key: navbarKeys[2],),
            
                const SizedBox(height: 30,),

                //About Me
                AboutMeSection(key: navbarKeys[3]),

                const SizedBox(height: 30,),
                
                //CONTACT
                ContactSection(key: navbarKeys[4]),
            
                //FOOTER
                const Footer(),
              ],
            ),
          ));
      }
    );
  }

  void scrollToSection(int navIndex){

    final key = navbarKeys[navIndex];
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(microseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
