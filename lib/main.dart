import 'package:flutter/material.dart' hide CarouselController;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oh_yeah/screens/splash_page.dart';

import 'firebase_options.dart';

import 'package:oh_yeah/screens/news_detail_page.dart';
import 'package:oh_yeah/screens/home_page.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  String? initialNewsId;

  // Firebase 初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // local notification 初期化
  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(
    iOS: iosSettings,
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {

      final payload = details.payload;

      debugPrint("LOCAL PAYLOAD:");
      debugPrint(payload);

      if (payload != null && payload.isNotEmpty) {

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => NewsDetailPage(
              id: payload,
            ),
          ),
        );

      }

    },
  );

  // 通知許可
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // APNs token 発行待ち
  await Future.delayed(const Duration(seconds: 5));

  final apnsToken =
      await FirebaseMessaging.instance.getAPNSToken();

  debugPrint("APNS TOKEN:");
  debugPrint(apnsToken);

  final fcmToken =
      await FirebaseMessaging.instance.getToken();

  debugPrint("FCM TOKEN:");
  debugPrint(fcmToken);

  await FirebaseMessaging.instance.subscribeToTopic("news");

  debugPrint("TOPIC SUBSCRIBE SUCCESS");

  // Supabase 初期化
  await Supabase.initialize(
    url: 'https://ikezocnvlrhluxhxwfug.supabase.co',
    anonKey:
        'sb_publishable_Li_R5pqWubw4taEHevrYSA_IKDg42uQ',
  );

  // 完全終了状態通知取得
  final initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {

    debugPrint("INITIAL MESSAGE:");
    debugPrint(initialMessage.data.toString());

    initialNewsId =
        initialMessage.data['newsId'];

    debugPrint("INITIAL NEWS ID:");
    debugPrint(initialNewsId);

  } else {

    debugPrint("INITIAL MESSAGE NULL");

  }

  // バックグラウンド通知タップ
  FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) {

      debugPrint("BACKGROUND MESSAGE:");
      debugPrint(message.data.toString());

      final newsId =
          message.data['newsId'];

      debugPrint("BACKGROUND NEWS ID:");
      debugPrint(newsId.toString());

      if (newsId != null) {

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => NewsDetailPage(
              id: newsId,
            ),
          ),
        );

      }

    },
  );

  // フォアグラウンド通知
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {

      debugPrint("FOREGROUND MESSAGE:");
      debugPrint(message.data.toString());

      final newsId =
          message.data['newsId'];

      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title ?? "",
        message.notification?.body ?? "",
        const NotificationDetails(
          iOS: DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
            'default',
            'default',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: newsId,
      );

    },
  );

  runApp(
    MyApp(
      initialNewsId: initialNewsId,
    ),
  );

}

class MyApp extends StatelessWidget {

  final String? initialNewsId;

  const MyApp({
    super.key,
    this.initialNewsId,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,

      title: 'Oh Yeah',

      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),

      home: initialNewsId != null
          ? NewsDetailPage(
              id: initialNewsId!,
            )
          : const SplashPage(),
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