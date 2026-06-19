// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/mqtt_service.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const IncubatorApp());
}

class IncubatorApp extends StatelessWidget {
  const IncubatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Auto-connect saat aplikasi dibuka
      create: (_) => MqttService()..connect(),
      child: MaterialApp(
        title: 'Inkubator Monitor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4ECDC4),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'sans-serif',
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
