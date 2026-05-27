import 'package:flutter/material.dart';

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:oh_yeah/screens/splash_page.dart';

import 'package:oh_yeah/screens/news_detail_page.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState>
    navigatorKey =
    GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel
    channel =
    AndroidNotificationChannel(

  'high_importance_channel',

  'High Importance Notifications',

  importance: Importance.high,

);

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Supabase
  await Supabase.initialize(

    url:
        'https://ikezocnvlrhluxhxwfug.supabase.co',

    anonKey:
        'sb_publishable_Li_R5pqWubw4taEHevrYSA_IKDg42uQ',

  );

  // Firebase
  await Firebase.initializeApp(

    options:
        DefaultFirebaseOptions.currentPlatform,

  );

  // 通知チャンネル作成
  await flutterLocalNotificationsPlugin

      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()

      ?.createNotificationChannel(
        channel,
      );

  // local notification 初期化
  const DarwinInitializationSettings
      iosSettings =
      DarwinInitializationSettings();

  const AndroidInitializationSettings
      androidSettings =
      AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const InitializationSettings
      initSettings =
      InitializationSettings(

    iOS: iosSettings,

    android: androidSettings,

  );

  await flutterLocalNotificationsPlugin
      .initialize(

    initSettings,

    onDidReceiveNotificationResponse:
        (details) {

      final payload =
          details.payload;

      if (payload != null &&
          payload.isNotEmpty) {

        navigatorKey.currentState
            ?.push(

          MaterialPageRoute(

            builder:
                (_) =>
                    NewsDetailPage(
              id: payload,
            ),

          ),

        );

      }

    },

  );

  // 通知許可
  final settings =
      await FirebaseMessaging.instance
          .requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint(
    "PERMISSION: ${settings.authorizationStatus}"
  );

  // APNS TOKEN
  if (Platform.isIOS) {
    final apnsToken =
        await FirebaseMessaging.instance
            .getAPNSToken();

    debugPrint("APNS TOKEN:");

    debugPrint(
      apnsToken ?? "NULL",
    );
  }

  // FCM TOKEN取得
  final fcmToken =
      await FirebaseMessaging.instance
          .getToken();

  debugPrint("FCM TOKEN:");

  debugPrint(fcmToken);

  await FirebaseMessaging.instance
      .deleteToken();

  final newToken =
      await FirebaseMessaging.instance
          .getToken();

  debugPrint("NEW FCM TOKEN:");
  debugPrint(newToken);

  // Topic解除
  await FirebaseMessaging.instance
      .unsubscribeFromTopic(
    "news",
  );

  // Topic再登録
  await FirebaseMessaging.instance
      .subscribeToTopic(
    "news",
  );

  debugPrint(
    "TOPIC RE-SUBSCRIBE SUCCESS",
  );

  // 完全終了通知
  final initialMessage =
      await FirebaseMessaging.instance
          .getInitialMessage();

  if (initialMessage != null) {

    final newsId =
        initialMessage
            .data['newsId'];

    if (newsId != null) {

      navigatorKey.currentState
          ?.push(

        MaterialPageRoute(

          builder:
              (_) =>
                  NewsDetailPage(
            id: newsId,
          ),

        ),

      );

    }

  }

  // バックグラウンド通知
  FirebaseMessaging
      .onMessageOpenedApp
      .listen(

    (RemoteMessage message) {

      final newsId =
          message.data['newsId'];

      if (newsId != null) {

        navigatorKey.currentState
            ?.push(

          MaterialPageRoute(

            builder:
                (_) =>
                    NewsDetailPage(
              id: newsId,
            ),

          ),

        );

      }

    },

  );

  // フォアグラウンド通知
  FirebaseMessaging.onMessage
      .listen(

    (RemoteMessage message) async {

      final newsId =
          message.data['newsId'];

      await flutterLocalNotificationsPlugin
          .show(

        0,

        message.notification
                ?.title ??
            "",

        message.notification
                ?.body ??
            "",

        NotificationDetails(

          iOS:
              const DarwinNotificationDetails(),

          android:
              AndroidNotificationDetails(

            channel.id,

            channel.name,

            importance:
                Importance.max,

            priority:
                Priority.high,

          ),

        ),

        payload: newsId,

      );

    },

  );

  runApp(
    const MyApp(),
  );

}

class MyApp
    extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {

    return MaterialApp(

      navigatorKey:
          navigatorKey,

      debugShowCheckedModeBanner:
          false,

      home: const SplashPage(),

    );

  }

}