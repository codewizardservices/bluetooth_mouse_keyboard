import 'package:bluetoothairmousekeyboard/extra/widgets_reusing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

generalPrintLog(String key, dynamic value) {
  if (kDebugMode) debugPrint("$key = $value");
}

class Constants {
  Constants._();

  //========= URL Launch ============================================

  static Future makeEmail(
    context, {
    required String toEmail,
    required String subject,
    required String body,
    String filePath = "",
  }) async {
    try {
      final launchUri =
          "mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(body)}&attachment=$filePath";

      canLaunchUrl(Uri.parse(launchUri)).then((value) async {
        if (value) {
          await launchUrl(Uri.parse(launchUri));
        } else {
          WidgetsReusing.getMaterialBar(context, "Not supported email");
        }
      });
    } catch (e) {
      WidgetsReusing.getMaterialBar(context, e.toString());
    }
  }

  static Future makePhoneCall(context, {required String phoneNumber}) async {
    try {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      canLaunchUrl(launchUri).then((value) async {
        if (value) {
          await launchUrl(launchUri);
        } else {
          WidgetsReusing.getMaterialBar(context, "Not supported call");
        }
      });
    } catch (e) {
      WidgetsReusing.getMaterialBar(context, e.toString());
    }
  }

  static Future<void> makePhoneSms(
    context, {
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {"": "", "body": message},
      );
      await launchUrl(launchUri);
    } catch (e) {
      WidgetsReusing.getMaterialBar(context, e.toString());
    }
  }

  static Future openUrlSite(context, String launchUri) async {
    try {
      canLaunchUrl(Uri.parse(launchUri)).then((value) async {
        if (value) {
          await launchUrl(Uri.parse(launchUri));
        } else {
          WidgetsReusing.getMaterialBar(context, "Not supported site");
        }
      });
    } catch (e) {
      WidgetsReusing.getMaterialBar(context, e.toString());
    }
  }

  //========= URL Launch ============================================
  static PageRouteBuilder openNewActivity(screen) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, _) {
        return FadeTransition(opacity: animation, child: screen);
      },
    );
  }

  static dynamic openNewScreenClean(context, materialRoutePage) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, _) {
          return FadeTransition(opacity: animation, child: materialRoutePage);
        },
      ),
      (Route<dynamic> route) => false,
    );
  }
}
