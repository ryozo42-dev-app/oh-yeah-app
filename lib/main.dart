import 'package:flutter/material.dart' hide CarouselController;
import 'package:supabase_flutter/supabase_flutter.dart';

// 🔥 画面
import 'package:oh_yeah/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ikezocnvlrhluxhxwfug.supabase.co',
    anonKey: 'sb_publishable_Li_R5pqWubw4taEHevrYSA_IKDg42uQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oh Yeah',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}