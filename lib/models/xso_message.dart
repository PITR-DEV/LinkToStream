import 'package:json_annotation/json_annotation.dart';

part 'xso_message.g.dart';

@JsonSerializable()
class XSOverlayMessage {
  int messageType =
      0; // 1 = Notification Popup, 2 = MediaPlayer Information, will be extended later on. int index = 0; //Only used for Media Player, changes the icon on the wrist.
  double timeout =
      0.5; //How long the notification will stay on screen for in seconds
  double height =
      175; //Height notification will expand to if it has content other than a title. Default is 175
  double opacity =
      1; //Opacity of the notification, to make it less intrusive. Setting to 0 will set to 1.
  double volume = 0.7; // Notification sound volume.
  String audioPath =
      ""; //File path to .ogg audio file. Can be "default", "error", or "warning". Notification will be silent if left empty.
  String title = ""; //Notification title, supports Rich Text Formatting
  String content =
      ""; //Notification content, supports Rich Text Formatting, if left empty, notification will be small.
  bool useBase64Icon = false; //Set to true if using Base64 for the icon image
  String icon =
      ""; //Base64 Encoded image, or file path to image. Can also be "default", "error", or "warning"
  String sourceApp = ""; //Somewhere to put your app name for debugging purposes

  XSOverlayMessage({
    this.messageType = 1,
    this.timeout = 2.5,
    this.height = 100,
    this.opacity = 1,
    this.volume = 0.7,
    this.audioPath = "default",
    required this.title,
    required this.content,
    this.useBase64Icon = false,
    this.icon = "",
    this.sourceApp = "",
  });

  Map<String, dynamic> toJson() => _$XSOverlayMessageToJson(this);
}
