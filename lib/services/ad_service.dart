/* // Uncomment the entire file to enable AdMob functionality

import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform; // To check platform

// Service class to manage Google Mobile Ads (AdMob)
class AdService {
  // --- Singleton Pattern ---
  // Ensures only one instance of the AdService exists.
  AdService._privateConstructor();
  static final AdService instance = AdService._privateConstructor();
  // --- End Singleton ---

  // --- Ad State ---
  BannerAd? _bannerAd; // Holds the banner ad object
  bool _isBannerAdLoaded = false; // Tracks if the banner ad is ready to show
  InterstitialAd? _interstitialAd; // Holds the interstitial ad object
  bool _isInterstitialAdLoaded = false; // Tracks if the interstitial ad is ready
  final int _maxFailedLoadAttempts = 3; // Max load retries for interstitial
  int _interstitialLoadAttempts = 0; // Current retry count for interstitial

  // --- Ad Unit IDs ---
  // IMPORTANT: Replace with your actual Ad Unit IDs from AdMob.
  // Using test IDs is crucial during development to avoid policy violations.
  // Test IDs documentation:
  // Android: https://developers.google.com/admob/android/test-ads
  // iOS: https://developers.google.com/admob/ios/test-ads

  // Provides the correct banner ad unit ID based on platform and build mode.
  String get bannerAdUnitId {
    if (kDebugMode) {
      // Use Google's provided test IDs during debugging
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Test Banner
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Test Banner
    } else {
      // Use your production Ad Unit IDs when building for release
      return Platform.isAndroid
          ? 'YOUR_ANDROID_BANNER_AD_UNIT_ID' // Replace with your actual ID
          : 'YOUR_IOS_BANNER_AD_UNIT_ID'; // Replace with your actual ID
    }
  }

  // Provides the correct interstitial ad unit ID based on platform and build mode.
  String get interstitialAdUnitId {
     if (kDebugMode) {
      // Use Google's provided test IDs during debugging
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android Test Interstitial
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS Test Interstitial
    } else {
      // Use your production Ad Unit IDs when building for release
      return Platform.isAndroid
          ? 'YOUR_ANDROID_INTERSTITIAL_AD_UNIT_ID' // Replace with your actual ID
          : 'YOUR_IOS_INTERSTITIAL_AD_UNIT_ID'; // Replace with your actual ID
    }
  }

  // --- Initialization ---
  // Initializes the Google Mobile Ads SDK. Call this once at app startup.
  void initialize() {
    // Check if already initialized or running on an unsupported platform
    // (AdMob currently supports Android and iOS).
    if (MobileAds.instance == null || !(Platform.isAndroid || Platform.isIOS)) {
        debugPrint("AdMob Service: Not initializing (already done or unsupported platform).");
        return;
    }
    MobileAds.instance.initialize();
    debugPrint("AdMob Service: SDK Initialized.");
    // Pre-load ads after initialization for quicker display later.
    // This is optional; ads can also be loaded just before they are needed.
    loadBannerAd();
    loadInterstitialAd();
  }


  // --- Banner Ad Logic ---
  // Loads a banner ad.
  void loadBannerAd() {
     if (!(Platform.isAndroid || Platform.isIOS)) return; // Check platform support
     if (_bannerAd != null) return; // Avoid loading if one is already loaded/loading

     debugPrint("AdMob Service: Loading Banner Ad...");
     _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      // Common banner size. Use AdSize.adaptiveBanner for better fit.
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdMob Service: Banner Ad loaded successfully.');
          _isBannerAdLoaded = true;
          // The ad is ready, but display is handled by the UI widget.
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('AdMob Service: Banner Ad failed to load: $err');
          _isBannerAdLoaded = false;
          ad.dispose(); // Clean up the failed ad object
          _bannerAd = null; // Clear the reference
          // Optionally retry loading after a delay
        },
        // Other optional callbacks:
        // onAdOpened: (Ad ad) => debugPrint('AdMob Service: Banner Ad opened.'),
        // onAdClosed: (Ad ad) => debugPrint('AdMob Service: Banner Ad closed.'),
        // onAdImpression: (Ad ad) => debugPrint('AdMob Service: Banner Ad impression.'),
      ),
    )..load(); // Start loading the ad immediately after creation.
  }

  // Builds the widget to display the banner ad.
  // Call this from your Scaffold's bottomNavigationBar or another suitable place.
  Widget? buildBannerWidget() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      // If the ad is loaded, return the AdWidget placed in a Container.
      return Container(
        alignment: Alignment.center,
        // Use the actual ad size for the container dimensions.
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!), // The widget that displays the ad content.
      );
    } else {
      // If the ad is not loaded, return null or an empty widget.
      // Returning null means no space will be reserved.
      // Return SizedBox(height: AdSize.banner.height.toDouble()) to reserve space.
      return null;
    }
  }

  // Disposes the current banner ad resources. Call when the ad is no longer needed.
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
     debugPrint("AdMob Service: Banner Ad disposed.");
  }


  // --- Interstitial Ad Logic ---
  // Loads an interstitial ad.
  void loadInterstitialAd() {
     if (!(Platform.isAndroid || Platform.isIOS)) return; // Check platform support
     if (_interstitialAd != null) return; // Avoid loading if already loaded/loading

     debugPrint("AdMob Service: Loading Interstitial Ad...");
     InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Called when the ad is successfully loaded.
        onAdLoaded: (ad) {
          debugPrint('AdMob Service: Interstitial Ad loaded successfully.');
          _interstitialAd = ad; // Store the loaded ad
          _isInterstitialAdLoaded = true;
          _interstitialLoadAttempts = 0; // Reset retry counter on success
          _interstitialAd!.setImmersiveMode(true); // Optional: Hide status/nav bars when ad shows

           // Set up callbacks for when the ad is shown/dismissed/fails to show.
           // This MUST be done after the ad is loaded.
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                debugPrint('AdMob Service: Interstitial Ad showed full screen.'),
            // Called when the ad is dismissed by the user.
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              debugPrint('AdMob Service: Interstitial Ad dismissed.');
              ad.dispose(); // Dispose the ad after dismissal
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              loadInterstitialAd(); // Preload the next interstitial ad.
            },
            // Called if the ad fails to show (e.g., due to an internal error).
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              debugPrint('AdMob Service: Interstitial Ad failed to show: $error');
              ad.dispose(); // Dispose the failed ad
               _interstitialAd = null;
               _isInterstitialAdLoaded = false;
              loadInterstitialAd(); // Try loading a new one.
            },
             // Other optional callbacks:
             // onAdImpression: (InterstitialAd ad) => debugPrint('AdMob Service: Interstitial Ad impression occurred.'),
          );

        },
        // Called if the ad fails to load from the network.
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('AdMob Service: Interstitial Ad failed to load: $error');
           _interstitialAd = null; // Ensure reference is cleared on failure
           _isInterstitialAdLoaded = false;
          _interstitialLoadAttempts += 1; // Increment retry counter
          // Retry loading up to a maximum number of attempts.
          if (_interstitialLoadAttempts <= _maxFailedLoadAttempts) {
             debugPrint('AdMob Service: Retrying interstitial load (attempt $_interstitialLoadAttempts)');
             // Optionally add a delay before retrying to avoid spamming requests.
             Future.delayed(const Duration(seconds: 5), () => loadInterstitialAd());
          } else {
             debugPrint('AdMob Service: Max interstitial load attempts reached.');
          }
        },
      ),
    );
  }

  // Shows the loaded interstitial ad if it's ready.
  // Call this at appropriate points in your app (e.g., after completing a task).
  void showInterstitialAd() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      debugPrint("AdMob Service: Attempting to show Interstitial Ad.");
      _interstitialAd!.show(); // Show the ad full screen.
      // Reset flags immediately; callbacks will handle disposal and reloading.
      // _isInterstitialAdLoaded = false; // Handled by callbacks now
      // _interstitialAd = null; // Handled by callbacks now
    } else {
      debugPrint('AdMob Service: Interstitial Ad not ready yet.');
      // Optionally try loading again if it's not loaded/ready.
      if (!_isInterstitialAdLoaded) {
          loadInterstitialAd();
      }
    }
  }

   // Disposes the current interstitial ad resources.
   void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdLoaded = false;
     debugPrint("AdMob Service: Interstitial Ad disposed.");
  }

  // --- Dispose All ---
  // Disposes all ad resources. Call when the app is closing or ads are no longer needed.
  void disposeAllAds() {
     disposeBannerAd();
     disposeInterstitialAd();
      debugPrint("AdMob Service: All ads disposed.");
  }
}

*/ // End of commented-out AdMob service
