import 'package:flutter/material.dart';
import 'core/utils/locale_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final locale = await LocaleService.loadLocale();

  runApp(MyApp(startLocale: locale));
}
