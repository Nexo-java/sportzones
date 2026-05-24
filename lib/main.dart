import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/authentication/screens/splash_screen.dart';
import 'core/constants/app_colors.dart';
import 'core/utils/responsive_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportZones',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return ResponsiveAppFrame(child: child);
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryDark,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
