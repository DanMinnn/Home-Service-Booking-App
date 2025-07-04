import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_service/models/user.dart';
import 'package:home_service/repo/user_repository.dart';
import 'package:home_service/routes/route_name.dart';

import '../modules/notifications/model/fcm_token_req.dart';
import '../modules/notifications/repo/notification_repo.dart';
import '../providers/log_provider.dart';
import 'navigation_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationsRepo _notificationsRepo = NotificationsRepo();
  final UserRepository _userRepo = UserRepository();
  final LogProvider logger = LogProvider('::::FIREBASE-MESSAGING-SERVICE::::');
  late final User? user;
  // Initialize notification channels and request permissions
  Future<void> init() async {
    // Request permission for iOS devices
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    logger.log('User granted permission: ${settings.authorizationStatus}');

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    // Create notification channel for Android
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await loadUser();
    // Get FCM token and register it with backend
    await registerFCMToken();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  //load User repository
  Future<void> loadUser() async {
    try {
      await _userRepo.loadUserFromStorage();
      user = _userRepo.currentUser;
      if (user != null) {
        logger.log('User loaded successfully: ${user!.id}');
      } else {
        logger.log('No User found in storage');
      }
    } catch (e) {
      logger.log('Error loading User: $e');
    }
  }

  // Register FCM token with backend
  Future<void> registerFCMToken() async {
    final User? currentUser = _userRepo.currentUser;
    if (currentUser == null) {
      logger.log('No current User found, cannot register FCM token');
      return;
    }

    String? token = await _firebaseMessaging.getToken();
    if (token == null) {
      logger.log('Failed to get FCM token');
      return;
    }

    String deviceId = await _getDeviceId();

    try {
      await _notificationsRepo.registerFCMToken(
        FCMTokenReq(
          token: token,
          deviceId: deviceId,
          userId: currentUser.id,
        ),
      );

      logger.log('FCM token registered with backend successfully');
    } catch (e) {
      logger.log('Failed to register FCM token: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    logger.log("Received foreground message: ${message.data}");

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  // Handle when user taps on notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    logger.log("Opened app from notification: ${message.data}");
    // Navigate based on notification type
    _handleNotificationNavigation(message.data);
  }

  void _onSelectNotification(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  // Navigate based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final NavigationService navigationService = NavigationService();

    // Navigate based on notification type
    if (data['type'] == 'JOB_ACCEPTED') {
      // Navigate to accepted job details
      navigationService.navigateTo(RouteName.notifications);
    } else {
      // Default navigation to notifications screen
      navigationService.navigateTo('/notifications');
    }
  }

  // Get device ID for token registration
  Future<String> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      logger.log('Running on Android: ${androidInfo.id}');
      return androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }
    return 'unknown_device_id';
  }
}
