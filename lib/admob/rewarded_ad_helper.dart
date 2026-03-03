import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bluetoothairmousekeyboard/admob/admob_manage.dart';
import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';

class RewardedAdHelper {
  bool isAdLoaded = false;
  RewardedAd? _rewardedAd;

  // UPDATED: Removed the unused 'onEarnedReward' parameter from the loading method.
  // The reward callback is only relevant when the ad is shown.
  void loadRewardedAd({
    required Function() onAdShowFullScreen,
    required Function() onAdDismissed,
  }) async {
    final status = await DatabaseBox.getSubscriptionStatus();
    if (status.name == SubscriptionStatus.adsFree.name) {
      return;
    }

    RewardedAd.load(
      adUnitId: AdmobManager.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          isAdLoaded = true;
          _rewardedAd = ad;

          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (RewardedAd rewardedAd) {
              onAdShowFullScreen();
            },
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              isAdLoaded = false;
              _rewardedAd = null;
              onAdDismissed();
              // Preload the next ad
              loadRewardedAd(
                onAdDismissed: onAdDismissed,
                onAdShowFullScreen: onAdShowFullScreen,
              );
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              _rewardedAd = null;
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

  /// Shows the ad if available. Returns true if an ad was shown, false otherwise.
  bool showAdIfAvailable(Function(RewardItem reward) onEarnedReward) {
    if (_rewardedAd != null && isAdLoaded) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          onEarnedReward(rewardItem);
        },
      );
      return true;
    }
    return false;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}

final RewardedAdHelper rewardedAdHelper = RewardedAdHelper();
final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>(); // Add a key

//
// @override
// void initState() {
//   super.initState();
//
//   rewardedAdHelper.loadRewardedAd(
//     onEarnedReward: (reward) {
//      debugPrint("User earned reward: ${reward.amount}");
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
//   rewardedAdHelper.dispose();
//
//   super.dispose();
// }

// ElevatedButton(
// onPressed: () {
// rewardedAdHelper.showAdIfAvailable((reward) {
//debugPrint("✔ Rewarded: ${reward.amount} ${reward.type}");
// });
// },
// child: const Text("Show Rewarded Ad"),
// ),
