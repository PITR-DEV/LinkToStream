import 'dart:io';

import 'package:flutter/material.dart';
import 'package:linktostream/helper/prefs_helper.dart';
import 'package:linktostream/notification_layer.dart';
import 'package:linktostream/screens/main_screen.dart';
import 'package:linktostream/screens/settings_screen.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    setWindowMinSize(const Size(600, 320));
    setWindowMaxSize(const Size(720, 480));
  }

  await initSharedPreferences();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationLayer(
      MaterialApp(
        title: 'LinkToStream',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorSchemeSeed: const Color.fromARGB(255, 230, 255, 1),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const MainScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
