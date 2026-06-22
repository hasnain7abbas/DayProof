import 'package:flutter/material.dart';

import 'app.dart';
import 'data/storage/local_storage_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = LocalStorageService();
  await storage.init();

  final notifications = NotificationService();
  await notifications.init();

  runApp(DayProofApp(storage: storage, notifications: notifications));
}
