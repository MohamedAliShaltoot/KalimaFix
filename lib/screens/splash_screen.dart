import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kalima_fix/main.dart';
import 'package:kalima_fix/screens/keyboard_fix_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const KeyboardFixScreen()),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
        child: Center(
          child: Image.asset(
            "assets/images/app_logo.png",
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width,
           // height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }
}
