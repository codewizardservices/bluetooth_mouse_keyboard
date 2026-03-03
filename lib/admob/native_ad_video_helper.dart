import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bluetoothairmousekeyboard/admob/admob_manage.dart';
import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';

class NativeVideoAdHelper {
  NativeAd? _nativeAd; // only set when actually loaded
  BannerAd? _bannerAd; // only set when actually loaded

  bool _isLoadingNative = false;
  bool _isLoadingBanner = false;
  bool _disposed = false;

  final ValueNotifier<bool> isLoadedListenable = ValueNotifier<bool>(false);

  bool get isLoaded => _nativeAd != null || _bannerAd != null;

  double currentHeight({double nativeHeight = 350}) {
    if (_nativeAd != null) return nativeHeight;
    if (_bannerAd != null) return _bannerAd!.size.height.toDouble();
    return 0.0;
  }

  void _notify() => isLoadedListenable.value = isLoaded;

  /// Load chain: Native VIDEO -> Native STATIC -> Banner (MREC).
  void loadNativeAd(
    VoidCallback onAdStateChanged, {
    TemplateType type = TemplateType.medium,
  }) async {
    if (_disposed) return;
    if (_isLoadingNative || _isLoadingBanner || isLoaded) return;

    final status = await DatabaseBox.getSubscriptionStatus();
    if (status.name == SubscriptionStatus.adsFree.name) return;

    _isLoadingNative = true;

    _loadNative(
      adUnitId: AdmobManager.nativeVideoId,
      templateType: type,
      onAdStateChanged: onAdStateChanged,
      onFail: () {
        _loadNative(
          adUnitId: AdmobManager.nativeId,
          templateType: type,
          onAdStateChanged: onAdStateChanged,
          onFail: () {
            _loadBannerFallback(onAdStateChanged);
          },
        );
      },
    );
  }

  // -------- Native loader used for both video + static ----------
  void _loadNative({
    required String adUnitId,
    required TemplateType templateType,
    required VoidCallback onAdStateChanged,
    required VoidCallback onFail,
  }) {
    if (_disposed) return;

    // Create a local ad; DO NOT assign to _nativeAd yet.
    final native = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: templateType),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          if (_disposed) {
            ad.dispose();
            return;
          }
          debugPrint('✅ NativeAd loaded: $adUnitId');

          _isLoadingNative = false;

          // Dispose any previous shown ad and set the freshly loaded one
          _nativeAd?.dispose();
          _bannerAd?.dispose();
          _bannerAd = null;
          _nativeAd = ad as NativeAd;

          _notify();
          onAdStateChanged();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (_disposed) {
            ad.dispose();
            return;
          }
          debugPrint('❌ NativeAd failed ($adUnitId): $error');
          ad.dispose();

          // Do NOT set _nativeAd here; we only set it on success.
          // Continue the chain.
          onFail();
        },
      ),
    );

    native.load(); // load, but keep it local until success
  }

  // -------- Banner fallback (MREC 300x250) ----------
  void _loadBannerFallback(VoidCallback onAdStateChanged) {
    if (_disposed) return;
    if (_isLoadingBanner || _bannerAd != null) return;

    _isLoadingNative = false;
    _isLoadingBanner = true;

    final banner = BannerAd(
      adUnitId: AdmobManager.banner,
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (_disposed) {
            ad.dispose();
            return;
          }
          debugPrint('🟨 BannerAd (MREC) loaded as fallback.');
          _isLoadingBanner = false;

          _nativeAd?.dispose();
          _nativeAd = null;

          // Assign only AFTER it has loaded
          _bannerAd?.dispose();
          _bannerAd = ad as BannerAd;

          _notify();
          onAdStateChanged();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (_disposed) {
            ad.dispose();
            return;
          }
          debugPrint('❌ BannerAd fallback failed: $error');
          _isLoadingBanner = false;

          ad.dispose();
          // Keep _bannerAd null on failure
          _notify();
          onAdStateChanged();
        },
      ),
    );

    banner.load(); // load, assign in onAdLoaded
  }

  Widget buildAdWidgetContainer({double nativeHeight = 370}) {
    if (_nativeAd != null) {
      return Padding(
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: nativeHeight,
          width: double.infinity,
          child: AdWidget(ad: _nativeAd!),
        ),
      );
    }
    if (_bannerAd != null) {
      final h = _bannerAd!.size.height.toDouble();
      final w = _bannerAd!.size.width.toDouble();
      return Padding(
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: h,
          width: w, // MREC is typically 300 wide
          child: Center(
            child: AdWidget(
              key: ValueKey(
                _bannerAd,
              ), // <- stable key, prevents platform view swap
              ad: _bannerAd!,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void dispose() {
    _disposed = true;
    _nativeAd?.dispose();
    _bannerAd?.dispose();
    _nativeAd = null;
    _bannerAd = null;
    _isLoadingNative = false;
    _isLoadingBanner = false;
    isLoadedListenable.dispose();
  }
}
