import 'package:flutter/material.dart';
import 'core/utils/locale_service.dart';
import 'app/app.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/notification_coordinator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final locale = await LocaleService.loadLocale();
  await NotificationService.instance.initialize();
  await NotificationCoordinator.rescheduleAll();

  runApp(MyApp(startLocale: locale));
}
