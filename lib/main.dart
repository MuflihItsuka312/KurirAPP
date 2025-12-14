// lib/main.dart
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'services/notification_service.dart';

void main() async {
  developer.log('=== KURIR APP V2 STARTING ===', name: 'KURIR');
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  developer.log('=== KURIR APP V2 READY ===', name: 'KURIR');
  runApp(const CourierApp());
}

class CourierApp extends StatelessWidget {
  const CourierApp({super.key});

  Future<Widget> _decideStartPage() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('courier_name') ?? '';
    final plate = prefs.getString('courier_plate') ?? '';
    if (name.isNotEmpty && plate.isNotEmpty) {
      return const CourierHomePage();
    }
    return const CourierLoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kurir App v2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _decideStartPage(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
