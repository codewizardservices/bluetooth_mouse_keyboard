
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bluetoothairmousekeyboard/admob/admob_manage.dart';
import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';

class InterstitialAdHelper {
  bool _isLoading = false;
  bool isAdLoaded = false;
  InterstitialAd? interstitialAd;

  Future<void> loadInterstitialAds({
    required VoidCallback onAdDismissed,
    required VoidCallback onAdShowFullScreen,
  }) async {
    if (_isLoading || isAdLoaded) return;

    final status = await DatabaseBox.getSubscriptionStatus();
    if (status.name == SubscriptionStatus.adsFree.name ||
        status.name == SubscriptionStatus.interstitialFree.name) {
      return;
    }

    _isLoading = true;

    InterstitialAd.load(
      adUnitId: AdmobManager.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          isAdLoaded = true;
          interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              onAdShowFullScreen();
            },
            onAdDismissedFullScreenContent: (ad) {
              isAdLoaded = false;
              ad.dispose();
              interstitialAd = null;
              onAdDismissed();
              // preload next
              loadInterstitialAds(
                onAdDismissed: onAdDismissed,
                onAdShowFullScreen: onAdShowFullScreen,
              );
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              isAdLoaded = false;
              ad.dispose();
              interstitialAd = null;
              // try to load another right away
              loadInterstitialAds(
                onAdDismissed: onAdDismissed,
                onAdShowFullScreen: onAdShowFullScreen,
              );
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          isAdLoaded = false;
          interstitialAd = null;
          debugPrint("❌ Interstitial failed: ${error.message}");
          // optional: retry after short delay
          Future.delayed(const Duration(seconds: 5), () {
            loadInterstitialAds(
              onAdDismissed: onAdDismissed,
              onAdShowFullScreen: onAdShowFullScreen,
            );
          });
        },
      ),
    );
  }

  Future<void> showAdIfAvailable(VoidCallback doNextFunctionality) async {
    final status = await DatabaseBox.getSubscriptionStatus();
    if (status.name == SubscriptionStatus.adsFree.name ||
        status.name == SubscriptionStatus.interstitialFree.name) {
      doNextFunctionality();
      return;
    }

    if (interstitialAd != null && isAdLoaded) {
      interstitialAd!.show();
      isAdLoaded = false; // ad is being shown
    } else {
      doNextFunctionality();
    }
  }

  void dispose() {
    interstitialAd?.dispose();
    interstitialAd = null;
  }
}
