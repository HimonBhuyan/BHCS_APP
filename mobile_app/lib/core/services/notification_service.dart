import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../router/app_router.dart';
import 'server_config.dart';

/// Top-level background FCM handler required by Firebase Messaging.
@pragma('vm:entry-point')
Future<void> bhFirebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if (title != null && body != null && message.notification == null) {
      await BhNotificationService.instance.ensurePluginInitialized();
      await BhNotificationService.instance.showLocalNotification(
        id: message.hashCode & 0x7FFFFFFF,
        title: title,
        body: body,
        category: message.data['category']?.toString() ?? 'Messages',
        targetRoute: message.data['targetRoute']?.toString() ?? '/notifications',
      );
    }
  } catch (_) {
    // Non-fatal background handler error
  }
}

/// Unified Android + iOS OS notification & FCM push manager for Blue Hour HQ.
class BhNotificationService {
  BhNotificationService._();
  static final BhNotificationService instance = BhNotificationService._();

  static const String _channelHigh = 'blue_hour_hq_high';
  static const String _channelMessages = 'blue_hour_hq_messages';
  static const String _channelMeetings = 'blue_hour_hq_meetings';
  static const String _channelLeads = 'blue_hour_hq_leads';

  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _pluginReady = false;
  String? _activeTopic;

  bool get _isTestEnv => Platform.environment.containsKey('FLUTTER_TEST');

  Future<void> ensurePluginInitialized() async {
    if (_pluginReady || _isTestEnv) return;
    try {
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
      );

      await _localPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = _localPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelHigh,
              'Blue Hour Executive Alerts',
              description: 'Critical studio alerts and system notifications',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            ),
          );
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelMessages,
              'Founders Direct Chat',
              description: 'Real-time messages from Founders Board & 1-on-1 DMs',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            ),
          );
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelMeetings,
              'Meetings & Calendar Reminders',
              description: 'Upcoming client demos and Founder sync reminders',
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            ),
          );
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelLeads,
              'CRM Leads & Follow-ups',
              description: 'New lead alerts and follow-up schedules',
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            ),
          );
        }
      }

      _pluginReady = true;
    } catch (_) {
      // Ignore initialization errors in headless environments
    }
  }

  Future<void> initialize() async {
    if (_initialized || _isTestEnv) return;
    _initialized = true;

    await ensurePluginInitialized();

    // Request OS notification permissions smoothly
    try {
      if (!kIsWeb && Platform.isAndroid) {
        await _localPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } else if (!kIsWeb && Platform.isIOS) {
        await _localPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    } catch (_) {}

    // Wire Firebase Cloud Messaging (FCM)
    if (Firebase.apps.isNotEmpty) {
      try {
        final fcm = FirebaseMessaging.instance;
        await fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        await fcm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        FirebaseMessaging.onBackgroundMessage(
          bhFirebaseMessagingBackgroundHandler,
        );

        await fcm.subscribeToTopic('blue_hour_hq_founders');

        FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
          final title = msg.notification?.title ??
              msg.data['title']?.toString() ??
              'Blue Hour HQ';
          final body =
              msg.notification?.body ?? msg.data['body']?.toString() ?? '';
          if (body.isNotEmpty) {
            unawaited(
              showLocalNotification(
                id: msg.hashCode & 0x7FFFFFFF,
                title: title,
                body: body,
                category: msg.data['category']?.toString() ?? 'Messages',
                targetRoute:
                    msg.data['targetRoute']?.toString() ?? '/notifications',
              ),
            );
          }
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
          final route = msg.data['targetRoute']?.toString();
          if (route != null && route.isNotEmpty) {
            _navigateToRoute(route);
          }
        });

        final initialMsg = await fcm.getInitialMessage();
        if (initialMsg != null) {
          final route = initialMsg.data['targetRoute']?.toString();
          if (route != null && route.isNotEmpty) {
            Future<void>.delayed(
              const Duration(milliseconds: 500),
              () => _navigateToRoute(route),
            );
          }
        }
      } catch (_) {
        // Non-fatal if FCM Play Services unavailable
      }
    }
  }

  /// Registers the active Founder's FCM device token in Cloud Firestore (`krypt-6a44c`).
  Future<void> syncFounderDeviceToken(String founderId, String founderName) async {
    if (_isTestEnv || Firebase.apps.isEmpty) return;
    try {
      final fcm = FirebaseMessaging.instance;
      final token = await fcm.getToken();

      final targetTopic = 'blue_hour_$founderId';
      if (_activeTopic != null && _activeTopic != targetTopic) {
        await fcm.unsubscribeFromTopic(_activeTopic!);
      }
      if (_activeTopic != targetTopic) {
        await fcm.subscribeToTopic(targetTopic);
        _activeTopic = targetTopic;
      }

      if (token != null && token.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('blue_hour_hq')
            .doc('fcm_tokens')
            .set(
          {
            founderId: {
              'token': token,
              'name': founderName,
              'platform': kIsWeb ? 'web' : Platform.operatingSystem,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          },
          SetOptions(merge: true),
        );
      }
    } catch (_) {
      // Non-blocking token sync
    }
  }

  String _channelForCategory(String category) {
    switch (category) {
      case 'Messages':
        return _channelMessages;
      case 'Meetings':
        return _channelMeetings;
      case 'Leads':
        return _channelLeads;
      default:
        return _channelHigh;
    }
  }

  NotificationDetails _detailsForCategory(String category) {
    final channelId = _channelForCategory(category);
    final channelName = switch (category) {
      'Messages' => 'Founders Direct Chat',
      'Meetings' => 'Meetings & Calendar Reminders',
      'Leads' => 'CRM Leads & Follow-ups',
      _ => 'Blue Hour Executive Alerts',
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: const BigTextStyleInformation(''),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String category = 'All',
    String targetRoute = '/notifications',
  }) async {
    if (_isTestEnv) return;
    await ensurePluginInitialized();
    try {
      await _localPlugin.show(
        id,
        title,
        body,
        _detailsForCategory(category),
        payload: targetRoute,
      );
    } catch (_) {}
  }

  /// Schedules native OS reminders (1 day, 1 hour, 15 minutes before, & at start).
  Future<void> scheduleReminderSequence({
    required String entityId,
    required String title,
    required String subtitle,
    required DateTime targetTime,
    String category = 'Meetings',
    String targetRoute = '/calendar',
  }) async {
    if (_isTestEnv) return;
    await ensurePluginInitialized();
    final now = DateTime.now();

    final intervals = <(String label, Duration offset)>[
      ('Tomorrow (1 day)', const Duration(days: 1)),
      ('In 1 hour', const Duration(hours: 1)),
      ('In 15 minutes', const Duration(minutes: 15)),
      ('Starting now', Duration.zero),
    ];

    for (var i = 0; i < intervals.length; i++) {
      final fireAt = targetTime.subtract(intervals[i].$2);
      if (fireAt.isAfter(now.add(const Duration(seconds: 5)))) {
        try {
          final tzFire = tz.TZDateTime.from(fireAt, tz.local);
          final notifId = (entityId.hashCode + i) & 0x7FFFFFFF;
          try {
            await _localPlugin.zonedSchedule(
              notifId,
              '$title • ${intervals[i].$1}',
              subtitle,
              tzFire,
              _detailsForCategory(category),
              payload: targetRoute,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          } catch (_) {
            await _localPlugin.zonedSchedule(
              notifId,
              '$title • ${intervals[i].$1}',
              subtitle,
              tzFire,
              _detailsForCategory(category),
              payload: targetRoute,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          }
        } catch (_) {}
      }
    }
  }

  static const int _dailyBriefingNotifId = 880880;

  /// Schedules or cancels the recurring automated daily Founder Briefing push.
  Future<void> scheduleDailyFounderBriefing({
    required bool enabled,
    required int hour,
    required int minute,
    required String summaryBody,
  }) async {
    if (_isTestEnv) return;
    await ensurePluginInitialized();
    try {
      await _localPlugin.cancel(_dailyBriefingNotifId);
    } catch (_) {}
    if (!enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour.clamp(0, 23),
      minute.clamp(0, 59),
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    try {
      await _localPlugin.zonedSchedule(
        _dailyBriefingNotifId,
        'Blue Hour HQ • Morning Founder Digest',
        summaryBody,
        scheduled,
        _detailsForCategory('Announcements'),
        payload: '/home',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  void _handleNotificationTap(NotificationResponse response) {
    final route = response.payload;
    if (route != null && route.isNotEmpty) {
      _navigateToRoute(route);
    }
  }

  void _navigateToRoute(String route) {
    try {
      const shellTabs = <String>{
        '/home',
        '/leads',
        '/chat',
        '/projects',
        '/profile',
      };
      if (shellTabs.contains(route)) {
        appRouter.go(route);
      } else {
        appRouter.push(route);
      }
    } catch (_) {}
  }

  /// Dispatches a real FCM HTTP v1 push via the live PHP/MySQL backend so
  /// recipient Founders receive notifications even when their app is closed.
  Future<void> dispatchRemoteFcmPush({
    required String title,
    required String body,
    required String senderId,
    String category = 'Messages',
    String targetRoute = '/notifications',
    List<String>? targetFounderIds,
    bool includeAllFounders = false,
  }) async {
    if (_isTestEnv) return;
    final pushEndpoints = BhServerConfig.instance.actionUrls('send_push');
    final client = HttpClient()
      ..connectionTimeout = const Duration(milliseconds: 2000);
    try {
      final encoded = jsonEncode({
        'title': title,
        'body': body,
        'category': category,
        'targetRoute': targetRoute,
        'senderId': senderId,
        'targetFounderIds': ?targetFounderIds,
        if (includeAllFounders) 'includeAllFounders': true,
      });
      for (final url in pushEndpoints) {
        try {
          final req = await client.postUrl(Uri.parse(url));
          req.headers.contentType = ContentType.json;
          req.write(encoded);
          final resp = await req.close();
          await resp.drain<void>();
          if (resp.statusCode == 200) break;
        } catch (_) {
          // Try next endpoint
        }
      }
    } catch (_) {
      // Non-blocking remote push dispatch
    } finally {
      client.close(force: true);
    }
  }

  /// Clears delivered local/FCM banners from the OS tray once read in-app.
  Future<void> clearDeliveredNotifications() async {
    if (_isTestEnv) return;
    try {
      await _localPlugin.cancelAll();
    } catch (_) {}
  }
}

