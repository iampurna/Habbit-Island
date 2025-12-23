import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habbit_island/core/utils/app_logger.dart';
import 'analytics_service.dart';

/// Notification Service
/// Handles push notifications (FCM) and local notifications
/// Reference: Technical Specification Addendum §7 (Notifications)

class NotificationService {
  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final AnalyticsService _analytics;

  String? _fcmToken;
  bool _isInitialized = false;

  NotificationService({required AnalyticsService analytics})
    : _fcm = FirebaseMessaging.instance,
      _localNotifications = FlutterLocalNotificationsPlugin(),
      _analytics = analytics;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize notification services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.debug('Initializing notification service...');

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await requestPermissions();

      // Get FCM token
      _fcmToken = await _fcm.getToken();
      if (_fcmToken != null) {
        NotificationLogger.fcmTokenReceived(_fcmToken!);
      }

      // Listen to token refresh
      _fcm.onTokenRefresh.listen((token) {
        _fcmToken = token;
        AppLogger.debug('FCM token refreshed');
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle notification taps when app is terminated
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      NotificationLogger.initialized();
      _isInitialized = true;
    } catch (e, stackTrace) {
      NotificationLogger.initializationFailed(e);
      AppLogger.error('Notification initialization failed', e, stackTrace);
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  // ============================================================================
  // PERMISSIONS
  // ============================================================================

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (granted) {
      NotificationLogger.permissionGranted();
    } else {
      NotificationLogger.permissionDenied();
    }

    return granted;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _fcm.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // ============================================================================
  // FCM TOKEN
  // ============================================================================

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    AppLogger.debug('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    AppLogger.debug('Unsubscribed from topic: $topic');
  }

  // ============================================================================
  // LOCAL NOTIFICATIONS
  // ============================================================================

  /// Schedule habit reminder notification
  Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required DateTime scheduledTime,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Reminders for your daily habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      'Time for: $habitName',
      'Don\'t break your streak! Complete your habit now. 🔥',
      _convertToTZDateTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    NotificationLogger.notificationScheduled(habitName, scheduledTime);
  }

  /// Schedule daily streak reminder
  Future<void> scheduleDailyStreakReminder({required DateTime time}) async {
    await scheduleHabitReminder(
      id: 999999, // Special ID for daily reminder
      habitName: 'Your Daily Habits',
      scheduledTime: time,
    );
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
    NotificationLogger.notificationShown(title);
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    AppLogger.debug('Notification cancelled: $id');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    AppLogger.debug('All notifications cancelled');
  }

  // ============================================================================
  // MILESTONE NOTIFICATIONS
  // ============================================================================

  /// Show streak milestone notification
  Future<void> showStreakMilestone({
    required String habitName,
    required int streakDays,
    required int xpEarned,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🔥 $streakDays Day Streak!',
      body: '$habitName - You earned $xpEarned XP! Keep it up!',
    );
  }

  /// Show level up notification
  Future<void> showLevelUp({required int newLevel}) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '⬆️ Level Up!',
      body: 'Congratulations! You\'re now Level $newLevel!',
    );
  }

  /// Show all daily complete notification
  Future<void> showAllDailyComplete({required int bonusXp}) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🎉 All Daily Habits Complete!',
      body: 'Amazing work! You earned a +$bonusXp XP bonus!',
    );
  }

  // ============================================================================
  // MESSAGE HANDLERS
  // ============================================================================

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    NotificationLogger.messageReceived(message.messageId ?? 'unknown');

    // Show local notification
    if (message.notification != null) {
      showNotification(
        id: message.hashCode,
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }

    _analytics.logCustomEvent(
      eventName: 'notification_received',
      parameters: {'type': 'foreground', 'message_id': message.messageId},
    );
  }

  /// Handle message opened (background/terminated)
  void _handleMessageOpenedApp(RemoteMessage message) {
    NotificationLogger.messageOpened(message.messageId ?? 'unknown');

    _analytics.logCustomEvent(
      eventName: 'notification_opened',
      parameters: {
        'message_id': message.messageId,
        'data': message.data.toString(),
      },
    );

    //DOs: Navigate based on message data
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    AppLogger.debug('Local notification tapped: ${response.id}');

    _analytics.logCustomEvent(
      eventName: 'local_notification_tapped',
      parameters: {
        'id': response.id.toString(),
        'payload': response.payload ?? '',
      },
    );

    //DOs: Handle navigation based on payload
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Convert DateTime to TZDateTime
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // Note: You'll need to add timezone package for proper implementation
    // For now, returning DateTime (will need timezone conversion in production)
    return dateTime;
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.debug('Background message: ${message.messageId}');
  // Handle background message
}
