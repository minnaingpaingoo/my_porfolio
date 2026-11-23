import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';
import 'package:my_porfolio/firebase_options.dart';
import 'package:my_porfolio/pages/admin_panel_page.dart';
import 'package:my_porfolio/pages/home_page.dart';
import 'package:my_porfolio/services/portfolio_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization skipped or offline: $e');
  }
  await PortfolioRepository.instance.initializeFirebaseSync();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Naing Paing Oo · Developer Storybook',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: CustomColor.scaffoldBg,
        colorScheme: const ColorScheme.dark(
          primary: CustomColor.yellowPrimary,
          secondary: CustomColor.yellowSecondary,
          surface: CustomColor.bgLight1,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/admin': (context) => const AdminPanelPage(),
      },
    );
  }
}
