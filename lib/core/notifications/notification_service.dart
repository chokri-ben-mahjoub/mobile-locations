import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';

const _channelId = 'contract_expiry';
const _channelName = 'Expiration des contrats';
const _channelDescription =
    'Rappels avant la date de fin des contrats de location';

/// Gère la programmation des notifications locales de rappel d'expiration
/// de contrat. Un seul rappel par contrat (id stable dérivé de son uuid).
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  int _notificationId(String contractId) => contractId.hashCode & 0x7fffffff;

  Future<void> cancelForContract(String contractId) {
    return _plugin.cancel(_notificationId(contractId));
  }

  Future<void> scheduleForContract(Contract contract, int leadMonths) async {
    await cancelForContract(contract.id);

    final now = DateTime.now();
    if (!contract.endDate.isAfter(now)) return; // déjà expiré

    var reminderDate = DateTime(
      contract.endDate.year,
      contract.endDate.month - leadMonths,
      contract.endDate.day,
      9,
    );
    if (reminderDate.isBefore(now)) {
      // Le rappel théorique est déjà passé mais le contrat court encore :
      // on notifie bientôt pour rattraper le retard.
      reminderDate = now.add(const Duration(seconds: 10));
    }

    final scheduled = tz.TZDateTime.from(reminderDate, tz.local);
    final endLabel =
        '${contract.endDate.day.toString().padLeft(2, '0')}/${contract.endDate.month.toString().padLeft(2, '0')}/${contract.endDate.year}';

    await _plugin.zonedSchedule(
      _notificationId(contract.id),
      'Contrat bientôt expiré',
      '${contract.tenantName} — Local ${contract.unitNumber} expire le $endLabel.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> rescheduleAll(List<Contract> contracts, int leadMonths) async {
    await _plugin.cancelAll();
    for (final contract in contracts) {
      await scheduleForContract(contract, leadMonths);
    }
  }
}

final notificationService = NotificationService();
