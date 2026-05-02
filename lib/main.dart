import 'package:flutter/material.dart' hide CarouselController;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// 🔥 画面
import 'package:oh_yeah/screens/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 通知許可
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // APNs token 発行待ち
  await Future.delayed(const Duration(seconds: 10));

  // APNs token取得
  final apnsToken =
      await FirebaseMessaging.instance.getAPNSToken();

  print('APNS TOKEN: $apnsToken');

  // 🔥 一旦 FCM TOKEN は止める
  // final fcmToken =
  //     await FirebaseMessaging.instance.getToken();
  //
  // print('FCM TOKEN: $fcmToken');

  // Supabase 初期化
  await Supabase.initialize(
    url: 'https://ikezocnvlrhluxhxwfug.supabase.co',
    anonKey:
        'sb_publishable_Li_R5pqWubw4taEHevrYSA_IKDg42uQ',
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