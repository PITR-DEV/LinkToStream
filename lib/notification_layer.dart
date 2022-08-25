import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:linktostream/consts.dart';
import 'package:linktostream/helper/prefs_helper.dart';
import 'package:linktostream/models/xso_message.dart';
import 'package:udp/udp.dart';

class NotificationLayer extends StatefulWidget {
  const NotificationLayer(this.child, {Key? key}) : super(key: key);
  final Widget child;

  @override
  State<NotificationLayer> createState() => NotificationLayerState();
}

class NotificationLayerState extends State<NotificationLayer> {
  static late NotificationLayerState instance;

  bool enableXSONotifications = false;

  Future<void> sendNotification() async {
    if (!enableXSONotifications) return;

    var messageObj = XSOverlayMessage(
      title: "LinkToStream",
      content: "Converted link is ready to be pasted.",
      sourceApp: "LinkToStream",
    );
    var bytes = utf8.encode(jsonEncode(messageObj.toJson()));

    const port = Port(42069);

    var sender = await UDP.bind(Endpoint.loopback(port: port));
    await sender.send(bytes, Endpoint.broadcast(port: port));
    sender.close();
  }

  void setEnableXSONotifications(bool value) {
    setState(() {
      enableXSONotifications = value;
    });
  }

  // Future<void> initializeServer() async {

  // }

  @override
  void initState() {
    super.initState();
    instance = this;

    if (sharedPreferences.getBool(PrefConsts.xsoNotifications) ?? false) {
      setEnableXSONotifications(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
