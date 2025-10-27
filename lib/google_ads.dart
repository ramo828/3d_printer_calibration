import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAds {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  void loadAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: _testAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _isLoaded = true;
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          _bannerAd = null;
          _isLoaded = false;
        },
        onAdOpened: (ad) {
          debugPrint('$ad opened.');
        },
        onAdClosed: (ad) {
          debugPrint('$ad closed.');
        },
        onAdImpression: (ad) {
          debugPrint('$ad impression.');
        },
      ),
    );

    _bannerAd!.load();
  }

  bool get isAdLoaded => _isLoaded;

  Widget? getAdWidget() {
    if (_bannerAd != null && _isLoaded) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }
}
