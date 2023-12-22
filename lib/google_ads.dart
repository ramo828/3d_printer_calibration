import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Google_ads {
  BannerAd? bannerAd;
  bool _isLoaded = false;

  /// Loads a banner ad.
  void loadAd() {
    bannerAd = BannerAd(
      adUnitId: "ca-app-pub-3962458560603198/8372025013",
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _isLoaded = true;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }
}
