import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class Utilites {

  static showSnackBar({required BuildContext context, required String text} ){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  static void shareApp() {
  if (!Platform.isAndroid) return;

  const packageName = 'com.smarttvmousekeyboard.bluetoothairmousekeyboard';
  final url = 'https://play.google.com/store/apps/details?id=$packageName';

  Share.share(
    'Check out this cool app: $url',
    subject: 'Awesome App',
  );
}

static Future<void> rateUs() async {
  if (!Platform.isAndroid) return;

  final inAppReview = InAppReview.instance;

  if (await inAppReview.isAvailable()) {
    await inAppReview.requestReview();
  } else {
    // fallback to Play Store page
    await inAppReview.openStoreListing(
      appStoreId: 'YOUR_APP_ID', // optional on Android
    );
  }
}

static Future<void> openPrivacyPolicy() async {
    const url = 'https://codstars.com/policy.html';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // opens in browser
      );
    } else {
      debugPrint('Could not launch $url');
    }
  }


}