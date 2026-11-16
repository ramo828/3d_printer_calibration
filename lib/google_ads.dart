import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ekranın altında gösterilen tek bir anchored adaptive banner reklamı yönetir.
class GoogleAds {
  /// Google'ın resmi banner test kimlikleri (Android ve iOS için ayrı).
  static const String _androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestBannerId =
      'ca-app-pub-3940256099942544/2934735716';

  static String get _testBannerId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? _iosTestBannerId
          : _androidTestBannerId;

  /// Gerçek kimlik build sırasında verilir:
  /// flutter build aab --release --dart-define=BANNER_AD_UNIT_ID=ca-app-pub-xxx/yyy
  /// Verilmezse test reklamı gösterilir (gelir getirmez).
  static const String _configuredBannerId =
      String.fromEnvironment('BANNER_AD_UNIT_ID');

  static String get _bannerId =>
      _configuredBannerId.isEmpty ? _testBannerId : _configuredBannerId;

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isDisposed = false;

  bool get isAdLoaded => _isLoaded && _bannerAd != null;

  /// [width] mantıksal piksel cinsinden ekran genişliğidir.
  /// Reklam yüklenince [onChanged] çağrılır (arayüzü yeniden çizmek için).
  Future<void> loadAd({required int width, VoidCallback? onChanged}) async {
    _release();

    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null || _isDisposed) {
      debugPrint('Adaptive banner boyutu alınamadı.');
      return;
    }

    final ad = BannerAd(
      adUnitId: _bannerId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _isLoaded = true;
          onChanged?.call();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          if (identical(_bannerAd, ad)) {
            _bannerAd = null;
            _isLoaded = false;
          }
          onChanged?.call();
        },
      ),
    );

    _bannerAd = ad;
    await ad.load();
  }

  Widget? getAdWidget() {
    final ad = _bannerAd;
    if (ad == null || !_isLoaded) return null;
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }

  void _release() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  void dispose() {
    _isDisposed = true;
    _release();
  }
}
