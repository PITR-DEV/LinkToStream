import 'dart:io';
import 'package:flutter/material.dart';
import 'package:linktostream/consts.dart';
import 'package:linktostream/helper/prefs_helper.dart';
import 'package:linktostream/notification_layer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          if (!Platform.isAndroid)
            ListTile(
              title: Text(
                'XSOverlay Notifications',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              subtitle: const Text(
                  'Triggers an XSOverlay notification when a link is converted'),
              trailing: Switch(
                value: NotificationLayerState.instance.enableXSONotifications,
                onChanged: (value) {
                  setState(() {
                    NotificationLayerState.instance
                        .setEnableXSONotifications(value);
                  });
                  sharedPreferences.setBool(PrefConsts.xsoNotifications, value);
                },
              ),
            ),
        ],
      ),
    );
  }
}
