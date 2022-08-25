import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;

Future<void> initSharedPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
}
