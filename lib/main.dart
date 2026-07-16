import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await DatabaseService.init();
  
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const HabbityApp());
}
