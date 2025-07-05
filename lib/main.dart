import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import 'package:nexttick/core/theme/app_theme.dart';
import 'package:nexttick/shared/services/calendar_service.dart';
import 'package:nexttick/shared/services/database_service.dart';
import 'package:nexttick/shared/services/notification_service.dart';
import 'package:nexttick/shared/widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await DatabaseService.instance.initialize();
  await CalendarService.instance.initialize();
  await NotificationService.instance.initialize();
  
  // Register Syncfusion license (using free community license)
  // Note: Replace with actual license key if using commercial version
  // SyncfusionLicense.registerLicense('YOUR_LICENSE_KEY');
  
  runApp(const NextTickApp());
}

class NextTickApp extends StatelessWidget {
  const NextTickApp({super.key});

  @override
  Widget build(final BuildContext context) => MaterialApp(
    title: 'NextTick',
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.system,
    home: const MainNavigation(),
  );
}
