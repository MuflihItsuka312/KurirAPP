import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service (local notifications only)
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions for Android 13+
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      print('[NOTIFICATION] Permission granted: $granted');
    }

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'smart_locker_channel',
      'Smart Locker Notifications',
      description: 'Notifications for locker events and package updates',
      importance: Importance.high,
      playSound: true,
    );

    await androidPlugin?.createNotificationChannel(androidChannel);

    print('[NOTIFICATION] ✅ Local notifications initialized');
    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('[NOTIFICATION] Notification tapped: ${response.payload}');
    // Navigate to appropriate page based on payload
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'smart_locker_channel',
      'Smart Locker Notifications',
      channelDescription: 'Notifications for locker events and package updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
    print('[NOTIFICATION] ✅ Shown: $title');
  }

  /// Show notification for locker opened
  Future<void> showLockerOpenedNotification({
    required String resi,
    required String lockerId,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🔓 Loker Terbuka',
      body: 'Loker $lockerId untuk paket $resi telah dibuka',
      payload: 'locker_opened:$resi',
    );
  }

  /// Show notification for locker closed
  Future<void> showLockerClosedNotification({
    required String resi,
    required String lockerId,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🔒 Loker Tertutup',
      body: 'Loker $lockerId untuk paket $resi telah ditutup',
      payload: 'locker_closed:$resi',
    );
  }

  /// Show notification for package detected (load cell)
  Future<void> showPackageDetectedNotification({
    required String resi,
    required String lockerId,
    required double weight,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📦 Paket Terdeteksi',
      body: 'Paket $resi (${weight.toStringAsFixed(1)} kg) terdeteksi di loker $lockerId',
      payload: 'package_detected:$resi',
    );
  }

  /// Show notification for package removed (load cell)
  Future<void> showPackageRemovedNotification({
    required String resi,
    required String lockerId,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '✅ Paket Diambil',
      body: 'Paket $resi telah diambil dari loker $lockerId',
      payload: 'package_removed:$resi',
    );
  }

  /// Show notification for package delivered
  Future<void> showPackageDeliveredNotification({
    required String resi,
    required String lockerId,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🎉 Paket Diterima',
      body: 'Paket $resi telah diterima di loker $lockerId. Silakan ambil paket Anda!',
      payload: 'package_delivered:$resi',
    );
  }

  /// Show notification for deposit success
  Future<void> showDepositSuccessNotification({
    required String resi,
    required String lockerId,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '✅ Paket Berhasil Dititipkan',
      body: 'Paket $resi berhasil dititipkan di loker $lockerId',
      payload: 'deposit_success:$resi',
    );
  }
}
