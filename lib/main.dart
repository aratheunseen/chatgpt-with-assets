import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatgpt/firebase_options.dart';
import 'package:chatgpt/admanager.dart';
import 'package:chatgpt/browser.dart';

// Start :: AppOpenAd
AppOpenAd? _appOpenAd;
bool _isShowingAd = false;

Future<void> loadAd() async {
  await AppOpenAd.load(
    adUnitId: AdManager.appOpenAdUnitId,
    orientation: AppOpenAd.orientationPortrait,
    request: const AdRequest(),
    adLoadCallback: AppOpenAdLoadCallback(onAdLoaded: (ad) {
      _appOpenAd = ad;
      _appOpenAd!.show();
    }, onAdFailedToLoad: (error) {
      _appOpenAd = null;
    }),
  );
}

void showAd() {
  if (_appOpenAd == null) {
    loadAd();
    return;
  }
  if (_isShowingAd) {
    return;
  }
  _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (ad) {
      _isShowingAd = true;
    },
    onAdFailedToShowFullScreenContent: (ad, error) {
      _isShowingAd = false;
      ad.dispose();
      _appOpenAd = null;
    },
    onAdDismissedFullScreenContent: (ad) {
      _isShowingAd = false;
      ad.dispose();
      _appOpenAd = null;
    },
  );
  _appOpenAd!.show();
}
// End :: AppOpenAd

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  loadAd();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const Browser(
        title: 'ChatGPT',
        url: 'https://chat.openai.com',
      ),
    );
  }
}
