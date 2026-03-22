import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 1.0;

  @override
  void initState() {
    super.initState();

    // 2秒後にフェード開始
    Timer(const Duration(milliseconds: 2500), () {
      setState(() {
        opacity = 0.0;
      });

      // フェード後に画面遷移
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 500),
          child: const Text(
            "Oh Yeah!",
            style: TextStyle(
              fontFamily: "Impact",
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}