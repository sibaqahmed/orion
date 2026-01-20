import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:orion/features/assistant/assistant_screen.dart';
import 'package:orion/features/auth/auth_gate.dart';
import 'package:orion/features/auth/login_screen.dart';
import 'package:orion/features/splash/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const OrionApp());
}

class OrionApp extends StatelessWidget {
  const OrionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home:  const SplashScreen(),
    );
  }
}
