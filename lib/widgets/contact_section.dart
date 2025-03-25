import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/constants/size.dart';
import 'package:my_porfolio/constants/sns_links.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection>  createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
        color: CustomColor.bgLight1,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title
              const Text(
                "Get In Touch",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CustomColor.whitePrimary,
                ),
              ),
              const SizedBox(height: 50),
              // Contact Form
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 700,
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth >= kMinDesktopWidth) {
                    return buildNameEmailFieldDesktop();
                  } else {
                    return buildNameEmailFieldMobile();
                  }
                }),
              ),
              const SizedBox(height: 30),
              // Message
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: TextFormField(
                  controller: _messageController,
                  maxLines: 16,
                  decoration: const InputDecoration(
                    hintText: "Your Message",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your message';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Send Button
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'naingpaingoo@gmail.com',
                          query: 'subject=Get In Touch From Porfolio&body=Name: ${_nameController.text}\nEmail: ${_emailController.text}\n\nMessage: ${_messageController.text}',
                        );
                        if (await canLaunchUrl(emailLaunchUri)) {
                          await launchUrl(emailLaunchUri);
                        } else {
                          // Handle the error
                          debugPrint('Could not launch $emailLaunchUri');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.yellowPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      foregroundColor: CustomColor.whitePrimary,
                    ),
                    child: const Text("Get In Touch"),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                ),
                child: const Divider(),
              ),
              const SizedBox(height: 15),
              // SNS icon button Links
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      final Uri phoneLaunchUri = Uri(
                        scheme: 'tel',
                        path: '+959790663667', 
                      );
                      if (await canLaunchUrl(phoneLaunchUri)) {
                        await launchUrl(phoneLaunchUri);
                      } else {
                        // Handle the error
                        debugPrint('Could not launch $phoneLaunchUri');
                      }
                    },
                    child: const Icon(
                      Icons.phone,
                      size: 28,
                      color: CustomColor.whitePrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse(SnsLinks.github))) {
                        await launchUrl(Uri.parse(SnsLinks.github));
                      }
                    },
                    child: Image.asset(
                      "assets/github.png",
                      width: 28,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse(SnsLinks.linkedin))) {
                        await launchUrl(Uri.parse(SnsLinks.linkedin));
                      }
                    },
                    child: Image.asset(
                      "assets/linkedin.png",
                      width: 28,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse(SnsLinks.twitter))) {
                        await launchUrl(Uri.parse(SnsLinks.twitter));
                      }
                    },
                    child: Image.asset(
                      "assets/twitter.png",
                      width: 28,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse(SnsLinks.facebook))) {
                        await launchUrl(Uri.parse(SnsLinks.facebook));
                      }
                    },
                    child: Image.asset(
                      "assets/facebook.png",
                      width: 28,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse(SnsLinks.instagram))) {
                        await launchUrl(Uri.parse(SnsLinks.instagram));
                      }
                    },
                    child: Image.asset(
                      "assets/ig.png",
                      width: 28,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse(SnsLinks.telegram))) {
                        await launchUrl(Uri.parse(SnsLinks.telegram));
                      }
                    },
                    child: Image.asset(
                      "assets/telegram.png",
                      width: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildNameEmailFieldDesktop() {
    return Row(
      children: [
        // Name
        Flexible(
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: "Your Name",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 15),
        // Email
        Flexible(
          child: TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              hintText: "Your Email",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Column buildNameEmailFieldMobile() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: "Your Name",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: "Your Email",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
      ],
    );
  }
}