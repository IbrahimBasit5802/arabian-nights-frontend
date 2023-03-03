import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';

void openURL(String url) async {
  try {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}
