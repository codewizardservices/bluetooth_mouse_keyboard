import 'dart:io';

import 'package:bluetoothairmousekeyboard/admob/admob_general_ids.dart';
import 'package:flutter/foundation.dart';

class AdmobManager {
  static bool get isAndroid => Platform.isAndroid;
  static bool get isTestingShowAdInDebug => true;
  static bool get isShowRealAds => true;

  static const _testIds = {
    "appId": "ca-app-pub-3940256099942544~3347511713",
    "banner": "ca-app-pub-3940256099942544/9214589741",
    "interstitial": "ca-app-pub-3940256099942544/1033173712",
    "rewardedInterstitial": "ca-app-pub-3940256099942544/5354046379",
    // "rewarded": "ca-app-pub-3940256099942544/5224354917",
    "rewarded": "ca-app-pub-3940256099942544/52244917",
    "native": "ca-app-pub-3940256099942544/2247696110",
    "nativeVideo": "ca-app-pub-3940256099942544/1044960115",
    // "appOpen": "ca-app-pub-3940256099942544/",
    "appOpen": "ca-app-pub-3940256099942544/9257395921",
  };

  static Map<String, String> get _ids =>
      kDebugMode
          ? (isTestingShowAdInDebug ? _testIds : {})
          : isShowRealAds
          ? (isAndroid ? androidIds : iosIds)
          : {};

  static String get appId => _ids["appId"] ?? "";
  static String get banner => _ids["banner"] ?? "";
  static String get interstitialId => _ids["interstitial"] ?? "";
  static String get rewardedInterstitialId =>
      _ids["rewardedInterstitial"] ?? "";
  static String get rewardedId => _ids["rewarded"] ?? "";
  static String get nativeId => _ids["native"] ?? "";
  static String get nativeVideoId => _ids["nativeVideo"] ?? "";
  static String get appOpenId => _ids["appOpen"] ?? "";
}
