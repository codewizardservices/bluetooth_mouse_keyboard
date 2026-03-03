import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bluetoothairmousekeyboard/admob/admob_manage.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';

// this class for handling interstitial ads showing handling if intersitial ads show dont show app open ads
class MyAppState {
  static final MyAppState _instance = MyAppState._internal();
  factory MyAppState() => _instance;
  MyAppState._internal();

  bool isOtherAdsDisabled = false;

  void updateValue(bool newValue) {
    isOtherAdsDisabled = newValue;
  }

  bool get getIsOtherAdsDisabled => isOtherAdsDisabled;
}

class AppOpenAdHelper {
  AppOpenAd? appOpenAd;
  bool isAdShowing = false;

  /// Loads an App Open Ad.
  void loadAppOpenAd() async {
    final status = await DatabaseBox.getSubscriptionStatus();
    if (status.name == SubscriptionStatus.adsFree.name) {
      return;
    }

    AppOpenAd.load(
      adUnitId: AdmobManager.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          appOpenAd = ad;
          appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              appOpenAd = null;
              isAdShowing = false;
              // Preload the next ad
              loadAppOpenAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              appOpenAd = null;
              isAdShowing = false;
              loadAppOpenAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          appOpenAd = null;
          // simple retry after short delay
          Future.delayed(const Duration(seconds: 20), () {
            loadAppOpenAd();
          });
        },
      ),
    );
  }

  /// Shows the ad if it's available and not currently suppressed by another ad.
  void showAdIfAvailable() {
    // If the flag is true, it means an interstitial ad was shown recently.
    if (MyAppState().getIsOtherAdsDisabled) {
      return;
    }

    if (appOpenAd == null || isAdShowing) {
      loadAppOpenAd();
      return;
    }

    isAdShowing = true;
    appOpenAd!.show();
  }
}
