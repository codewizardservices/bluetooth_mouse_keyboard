import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bluetoothairmousekeyboard/admob/admob_manage.dart';
import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';

class RewardedInterstitialAdHelper {
  bool isAdLoaded = false;
  RewardedInterstitialAd? _rewardedInterstitialAd;

  void loadRewardedInterstitialAd({
    required Function() onAdShowFullScreen,
    required Function() onAdDismissed,
  }) async {
    final status = await DatabaseBox.getSubscriptionStatus();
    if (status.name == SubscriptionStatus.adsFree.name) {
      return;
    }

    RewardedInterstitialAd.load(
      adUnitId: AdmobManager.rewardedInterstitialId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          isAdLoaded = true;
          _rewardedInterstitialAd = ad;

          _rewardedInterstitialAd
              ?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (RewardedInterstitialAd ad) {
              onAdShowFullScreen();
            },
            onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
              // FIXED: Do not call ad.dispose(). The SDK handles it.
              isAdLoaded = false;
              _rewardedInterstitialAd = null;
              onAdDismissed();
              // Preload the next ad
              loadRewardedInterstitialAd(
                onAdShowFullScreen: onAdShowFullScreen,
                onAdDismissed: onAdDismissed,
              );
            },
            onAdFailedToShowFullScreenContent: (
              RewardedInterstitialAd ad,
              AdError error,
            ) {
              // FIXED: Do not call ad.dispose().
              _rewardedInterstitialAd = null;
              isAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          isAdLoaded = false;
        },
      ),
    );
  }

  /// Shows the ad if available.
  /// IMPROVEMENT: Returns true if an ad was shown, false otherwise.
  bool showAdIfAvailable(Function(RewardItem reward) onEarnedReward) {
    if (_rewardedInterstitialAd != null && isAdLoaded) {
      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          // The reward callback should be passed in here, at the time of showing.
          onEarnedReward(rewardItem);
        },
      );
      return true; // Ad was shown
    }
    return false; // Ad was not ready
  }

  void dispose() {
    _rewardedInterstitialAd?.dispose();
  }
}

// final RewardedInterstitialAdHelper rewardedInterstitialAdHelper =
// RewardedInterstitialAdHelper();
//
// @override
// void initState() {
//   super.initState();
//
//   rewardedInterstitialAdHelper.loadRewardedInterstitialAd(
//     onEarnedReward: (reward) {
//      debugPrint("User earned reward from interstitial: ${reward.amount}");
//       Future.delayed(Duration(seconds: 30), () {
//         MyAppState().updateValue(false); // enable open ads after 30 sec
//       });
//     },
//     onAdDismissed: () {
//       Future.delayed(Duration(seconds: 30), () {
//         MyAppState().updateValue(false); // enable open ads after 30 sec
//       });
//     },
//     onAdShowFullScreen: () {
//       MyAppState().updateValue(true); // disabled app open ads
//     },
//   );
// }
//
// @override
// void dispose() {
//   rewardedInterstitialAdHelper.dispose();
//   super.dispose();
// }

// ElevatedButton(
// onPressed: () {
// rewardedInterstitialAdHelper.showAdIfAvailable((reward) {
// Future.delayed(Duration(seconds: 30), () {
// MyAppState()
//     .updateValue(false); // enable open ads after 30 sec
// });
//debugPrint(
// "✔ Rewarded Interstitial: ${reward.amount} ${reward.type}");
// });
// },
// child: const Text("Show Rewarded Interstitial Ad"),
// ),
