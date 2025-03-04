import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/size.dart';
import 'package:my_porfolio/constants/sns_links.dart';
import 'package:my_porfolio/widgets/custom_textfield.dart';
import 'package:url_launcher/url_launcher.dart'; 

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
      color: CustomColor.bgLight1,
      child: Column(children: [
        //title
        const Text(
          "Get In Touch",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CustomColor.whitePrimary,
          ),
        ),
        const SizedBox(height: 50),
        //Contact Form
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
            maxHeight: 115,
          ),
          child: LayoutBuilder(builder: (context, constraints){
            if(constraints.maxWidth >= kMinDesktopWidth){
              return buildNameEmailFieldDesktop();
            }else{
              return buildNameEmailFieldMobile();
            }
          }),
        ),
        const SizedBox(height: 20,),
        //Message
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: const CustomTextfield(
            hintText: "Your Message",
            maxLine: 16,
          ),
        ),
        const SizedBox(height: 20,),
        //Send Button
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.yellowPrimary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                foregroundColor: CustomColor.whitePrimary,
              ),
              child: const Text("Get In Touch"),
            ),
          ),
        ),

        const SizedBox(height: 30,),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 300,
          ),
          child: const Divider()),
          const SizedBox(height: 15,),
        //SNS icon button Links
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            InkWell(
              onTap: () async{
                if (await canLaunchUrl(Uri.parse(SnsLinks.github))) {
                  await launchUrl(Uri.parse(SnsLinks.github));
                }          
              },
              child: Image.asset("github.png", width: 28,)
            ),
            InkWell(
              onTap: () async{
                if (await canLaunchUrl(Uri.parse(SnsLinks.linkedin))) {
                  await launchUrl(Uri.parse(SnsLinks.linkedin));
                }
              },
              child: Image.asset("linkedin.png", width: 28,)
            ),
            InkWell(
              onTap: () async{
                if (await canLaunchUrl(Uri.parse(SnsLinks.twitter))) {
                  await launchUrl(Uri.parse(SnsLinks.twitter));
                }
              },
              child: Image.asset("twitter.png", width: 28,)
            ),
            InkWell(
              onTap: () async{
                if (await canLaunchUrl(Uri.parse(SnsLinks.facebook))) {
                  await launchUrl(Uri.parse(SnsLinks.facebook));
                }
              },
              child: Image.asset("facebook.png", width: 28,)
            ),
            InkWell(
              onTap: () async{
                if (await canLaunchUrl(Uri.parse(SnsLinks.instagram))) {
                  await launchUrl(Uri.parse(SnsLinks.instagram));
                }
              },
              child: Image.asset("ig.png", width: 28,)
            ),
            InkWell(
              onTap: () async{
                if (await canLaunchUrl(Uri.parse(SnsLinks.telegram))) {
                  await launchUrl(Uri.parse(SnsLinks.telegram));
                }
              },
              child: Image.asset("telegram.png", width: 28,)
            ),
          ],
        ),
      ],)
    );
  }

  Row buildNameEmailFieldDesktop(){
    return const Row(
      children: [
        //Name
        Flexible(
          child: CustomTextfield(
            hintText: "Your Name",
          ), 
        ),
        SizedBox(width: 15,),
        //Email
        Flexible(
          child: CustomTextfield(
            hintText: "Your Email",
          ), 
        ),
      ],
    );
  }
  
  Column buildNameEmailFieldMobile() {
    return const Column(
      children: [
        CustomTextfield(
          hintText: "Your Name",
        ),
        SizedBox(height: 15,),
        CustomTextfield(
          hintText: "Your Email",
        ),
      ],
    );
  }
}