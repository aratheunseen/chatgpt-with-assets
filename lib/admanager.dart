import 'dart:io';

// Start :: AdManager
class AdManager {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2474229370148368/5427317696';
      // } else if (Platform.isIOS) {
      //   return 'ca-app-pub-xxx';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2474229370148368/9215918260";
      // } else if (Platform.isIOS) {
      //   return "ca-app-pub-xxx";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2474229370148368/1778613075";
      // } else if (Platform.isIOS) {
      //   return "ca-app-pub-xxx";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // static String get nativeAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-2474229370148368/7442225061";
  //     // } else if (Platform.isIOS) {
  //     //   return "ca-app-pub-xxx";
  //   } else {
  //     throw UnsupportedError("Unsupported platform");
  //   }
  // }

  // static String get rewardedAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-2474229370148368/7442225061";
  //     // } else if (Platform.isIOS) {
  //     //   return "ca-app-pub-xxx";
  //   } else {
  //     throw UnsupportedError("Unsupported platform");
  //   }
  // }
}
// End :: AdManager
