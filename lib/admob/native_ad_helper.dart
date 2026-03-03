import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bluetoothairmousekeyboard/admob/admob_manage.dart';
import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';

class NativeAdHelper {
  NativeAd? _nativeAd;
  bool _isLoading = false;
  bool get isLoaded => _nativeAd != null;

  void loadNativeAd(
    VoidCallback onAdStateChanged, {
    TemplateType type = TemplateType.small,
  }) async {
    // 1. ADDED GUARD: Prevents reloading if an ad is already loaded or loading.
    if (_isLoading || isLoaded) {
      return;
    }
    _isLoading = true;

    final status = await DatabaseBox.getSubscriptionStatus();
    if (status.name == SubscriptionStatus.adsFree.name) {
      _isLoading = false;
      return; // Skip loading if purchased
    }

    _nativeAd = NativeAd(
      adUnitId: AdmobManager.nativeId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ NativeAd loaded.');
          _isLoading = false;
          onAdStateChanged(); // Rebuild UI
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("❌ NativeAd failed to load: $error");
          _isLoading = false;
          ad.dispose();
          _nativeAd = null; 
          onAdStateChanged(); 
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: type,
        // ... your other styling properties
      ),
    )..load();
  }

  // 2. CHANGED TO INSTANCE METHOD: No parameters needed, cleaner to call.
  Widget buildAdWidgetContainer({double height = 130}) {
    if (!isLoaded) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }

  void dispose() {
    print("NativeAdHelper: Disposing native ad.");
    _nativeAd?.dispose();
    _nativeAd = null;
  }
}
