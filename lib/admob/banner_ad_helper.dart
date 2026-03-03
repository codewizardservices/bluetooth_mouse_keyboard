import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bluetoothairmousekeyboard/admob/admob_manage.dart';
import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';

class BannerAdHelper {
  BannerAd? _bannerAd;
  bool _isLoading = false;
  int _retryCount = 0;
  static const int _maxRetry = 3;

  bool get isLoaded => _bannerAd != null;

  Future<void> loadBannerAd(
    BuildContext context,
    VoidCallback onAdStateChanged,
  ) async {
    if (_isLoading || isLoaded) return;

    _isLoading = true;

    // 1) respect subscription
    final status = await DatabaseBox.getSubscriptionStatus();
    if (status.name == SubscriptionStatus.adsFree.name) {
      _isLoading = false;
      return;
    }

    // 2) get proper adaptive size
    final width = MediaQuery.of(context).size.width.truncate();
    final adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (adSize == null) {
      _isLoading = false;
      return;
    }

    // 3) create banner
    _bannerAd = BannerAd(
      adUnitId: AdmobManager.banner,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner loaded');
          _isLoading = false;
          _retryCount = 0;
          onAdStateChanged();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner failed: $error');
          ad.dispose();
          _bannerAd = null;
          _isLoading = false;
          onAdStateChanged();
          _retryIfPossible(context, onAdStateChanged);
        },
      ),
    )..load();
  }

  void _retryIfPossible(
    BuildContext context,
    VoidCallback onAdStateChanged,
  ) {
    if (_retryCount >= _maxRetry) return;
    _retryCount++;

    // small backoff: 1s, 2s, 4s
    final delay = Duration(seconds: 1 << (_retryCount - 1));

    Timer(delay, () {
      // don’t start another if we already loaded in the meantime
      if (isLoaded || _isLoading) return;
      loadBannerAd(context, onAdStateChanged);
    });
  }

  Widget buildAdContainer() {
    if (!isLoaded) return const SizedBox.shrink();

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  void dispose() {
    debugPrint('BannerAdHelper: dispose');
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}
