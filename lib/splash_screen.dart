import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final text = "Oh Yeah!";

  late List<double> opacity;
  late List<double> rotation;

  @override
  void initState() {
    super.initState();

    opacity = List.filled(text.length, 0);
    rotation = List.filled(text.length, 0.25);

    startAnimation();
  }

  Future<void> startAnimation() async {
    await Future.delayed(const Duration(seconds: 2));
    // 1文字ずつ表示
    for (int i = 0; i < text.length; i++) {
      await Future.delayed(Duration(milliseconds: 180));

      setState(() {
        opacity[i] = 1.0;
        rotation[i] = 0.0;
      });
    }

    // 少し待つ
    await Future.delayed(Duration(milliseconds: 800));

    // フェードアウト
    setState(() {
      opacity = List.filled(text.length, 0);
    });

    await Future.delayed(Duration(milliseconds: 400));

    // 画面遷移
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainNavigationScreen(
        onMenuTap: () {
          // メニュー処理
        },
        onMapTap: () {
          // マップ処理
        },
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(text.length, (i) {
            return AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: opacity[i],
              child: AnimatedRotation(
                turns: rotation[i],
                duration: Duration(milliseconds: 300),
                child: Text(
                  text[i],
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}