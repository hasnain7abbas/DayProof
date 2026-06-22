import '../data/models/app_settings_model.dart';
import 'notification_service.dart';

class ReminderScheduler {
  ReminderScheduler(this._notifications);

  final NotificationService _notifications;

  Future<void> reschedule(AppSettingsModel settings) {
    return _notifications.scheduleDaily(settings);
  }
}
