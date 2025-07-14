import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform; // To check platform

// Service class to manage Google Mobile Ads (AdMob)
class AdService {
  // --- Singleton Pattern ---
  AdService._privateConstructor();
  static final AdService instance = AdService._privateConstructor();
  // --- End Singleton ---

  // --- Ad State ---
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  final int _maxFailedLoadAttempts = 3;
  int _interstitialLoadAttempts = 0;

  // --- Listener for UI updates ---
  VoidCallback? _onBannerAdStatusChanged;

  // --- Ad Unit IDs ---
  // IMPORTANT: Replace with your actual Ad Unit IDs
  String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Test Banner
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Test Banner
    } else {
      return Platform.isAndroid
          ? 'ca-app-pub-9761782466232974/7976147571' // Replace with your Android Banner ID
          : 'YOUR_IOS_BANNER_AD_UNIT_ID'; // Replace with your iOS Banner ID
    }
  }

  String get interstitialAdUnitId {
     if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android Test Interstitial
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test Interstitial
    } else {
      return Platform.isAndroid
          ? 'ca-app-pub-9761782466232974/6948090648'
          : 'YOUR_IOS_INTERSTITIAL_AD_UNIT_ID';
    }
  }

  // --- Initialization ---
  // This is now handled in main.dart by calling MobileAds.instance.initialize() directly.
  // We can pre-load ads here if desired.
  void loadAds() {
    loadBannerAd();
    loadInterstitialAd();
  }

  // --- Listener Management ---
  void setBannerListener(VoidCallback listener) {
    _onBannerAdStatusChanged = listener;
  }

  void removeBannerListener() {
    _onBannerAdStatusChanged = null;
  }

  // --- Banner Ad Logic ---
  void loadBannerAd() {
     if (_isBannerAdLoaded || _bannerAd != null) {
       // If an ad is already loaded or is in the process of loading, don't load another.
       // This prevents the "Ad with id X is not available" error.
       return;
     }
     if (!(Platform.isAndroid || Platform.isIOS)) return;

    debugPrint("AdMob Service: Loading Banner Ad...");
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdMob Service: Banner Ad loaded successfully.');
          _isBannerAdLoaded = true;
          // Notify the UI to rebuild
          _onBannerAdStatusChanged?.call();
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('AdMob Service: Banner Ad failed to load: $err');
          ad.dispose();
          _bannerAd = null;
          _isBannerAdLoaded = false;
           // Notify the UI that the ad failed (e.g., to hide the ad space)
          _onBannerAdStatusChanged?.call();
        },
      ),
    )..load();
  }

  Widget? buildBannerWidget() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Return null if the ad isn't loaded, so no space is taken.
    return null;
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
    // Notify the UI that the ad is gone
    _onBannerAdStatusChanged?.call();
    debugPrint("AdMob Service: Banner Ad disposed.");
  }


  // --- Interstitial Ad Logic ---
  void loadInterstitialAd() {
     if (_interstitialAd != null) return; // Don't load if already loaded/loading
     if (!(Platform.isAndroid || Platform.isIOS)) return;

     debugPrint("AdMob Service: Loading Interstitial Ad...");
     InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdMob Service: Interstitial Ad loaded successfully.');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _interstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              loadInterstitialAd(); // Preload the next one
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
               _interstitialAd = null;
               _isInterstitialAdLoaded = false;
              loadInterstitialAd(); // Try loading again
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('AdMob Service: Interstitial Ad failed to load: $error');
           _interstitialAd = null;
           _isInterstitialAdLoaded = false;
          _interstitialLoadAttempts += 1;
          if (_interstitialLoadAttempts <= _maxFailedLoadAttempts) {
             Future.delayed(const Duration(seconds: 5), () => loadInterstitialAd());
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint('AdMob Service: Interstitial Ad not ready yet.');
      if (!_isInterstitialAdLoaded) {
          loadInterstitialAd();
      }
    }
  }

  void disposeAllAds() {
     disposeBannerAd();
     _interstitialAd?.dispose();
     debugPrint("AdMob Service: All ads disposed.");
  }
}

