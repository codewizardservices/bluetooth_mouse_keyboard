// lib/ad_state_provider.dart (previously ad_state_provider.dart)
import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';
import 'package:flutter/material.dart';


class AdStateProvider extends ChangeNotifier {
  // 1. FOR IN-APP PURCHASE STATUS
  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;

  // 2. NEW: FOR FULL-SCREEN AD VISIBILITY
  bool _isFullScreenAdShowing = false;
  bool get isFullScreenAdShowing => _isFullScreenAdShowing;

  AdStateProvider() {
    checkSubscriptionStatus();
  }

  Future<void> checkSubscriptionStatus() async {
    final status = await DatabaseBox.getSubscriptionStatus();
    print("checkSubscriptionStatus: status.name ${status.name}");
    final newStatus = (status.name == SubscriptionStatus.adsFree.name);
    print("checkSubscriptionStatus: _isSubscribed ${_isSubscribed}");
    print(
      "checkSubscriptionStatus: _isSubscribed != newStatus ${_isSubscribed != newStatus}",
    );
    if (_isSubscribed != newStatus) {
      _isSubscribed = newStatus;
      notifyListeners();
    }
  }

  // NEW METHOD: To be called by Interstitial/Rewarded ads
  void setFullScreenAdShowing(bool value) {
    _isFullScreenAdShowing = value;
    notifyListeners();
  }
}
