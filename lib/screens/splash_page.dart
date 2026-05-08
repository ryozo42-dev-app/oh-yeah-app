import 'dart:async';

import 'package:flutter/material.dart';

import 'home_page.dart';

class SplashPage extends StatefulWidget {

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() =>
      _SplashPageState();

}

class _SplashPageState
    extends State<SplashPage>
    with SingleTickerProviderStateMixin {

  late AnimationController
      _controller;

  late Animation<double>
      _opacityAnimation;

  @override
  void initState() {

    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 4),
    );

    _opacityAnimation =
        TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.forward();

    Timer(
      const Duration(seconds: 4),
      () {

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const HomePage(),
          ),
        );

      },
    );

  }

  @override
  void dispose() {

    _controller.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFD9CFBE),

      body: Center(

        child: FadeTransition(

          opacity: _opacityAnimation,

          child: const Text(

            "Oh Yeah!",

            style: TextStyle(

              fontSize: 52,

              color: Colors.black,

              fontFamily: "jrmm00u",

              fontWeight: FontWeight.w700,

              letterSpacing: 1.2,

            ),

          ),

        ),

      ),

    );

  }

}