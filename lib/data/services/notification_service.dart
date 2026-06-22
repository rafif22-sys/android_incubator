import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Channel notifikasi Android untuk alarm inkubator pintar
  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
    'inkubator_alert_channel', // id
    'Notifikasi Inkubator Pintar', // title
    description:
        'Channel ini digunakan untuk notifikasi alarm inkubator pintar', // description
    importance: Importance.max,
    playSound: true,
  );

  /// Inisialisasi Notifikasi Lokal
  Future<void> initialize() async {
    print('NotificationService: Memulai inisialisasi...');
    try {
      // Konfigurasi Android settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      // Inisialisasi plugin
      print('NotificationService: Memanggil _localNotifications.initialize...');
      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          print('NotificationService: Notifikasi lokal diklik: ${details.payload}');
        },
      );

      // Minta izin untuk Android 13+
      print('NotificationService: Meminta izin notifikasi...');
      final granted = await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      print('NotificationService: Status izin: $granted');

      // Buat android notification channel
      print('NotificationService: Membuat channel notifikasi...');
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);

      print('NotificationService: Berhasil diinisialisasi secara lokal.');
    } catch (e, stackTrace) {
      print('NotificationService ERROR: Gagal menginisialisasi NotificationService: $e');
      print(stackTrace);
    }
  }

  /// Menampilkan notifikasi lokal secara manual
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    print('NotificationService: Menampilkan notifikasi: id=$id, title="$title", body="$body"');
    try {
      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: 'ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        payload: payload,
      );
      print('NotificationService: Berhasil memicu notifikasi untuk id=$id');
    } catch (e) {
      print('NotificationService ERROR: Gagal menampilkan notifikasi: $e');
    }
  }
}
