// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:chatgpt/admanager.dart';

class Browser extends StatefulWidget {
  const Browser({Key? key, required this.title, required this.url})
      : super(key: key);

  final String title;
  final String url;

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with TickerProviderStateMixin {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  // Declare WebView Controller
  late final WebViewController _controller;

  // Declare Ad variables
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  // Declare ProgressController
  late AnimationController progressController;
  bool determinate = false;

  @override
  void initState() {
    // Start :: LoadAd
    BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            FirebaseAnalytics.instance.logEvent(
              name: "ad_loaded",
              parameters: {
                "full_text": "Banner Ad Loaded",
              },
            );
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();

    InterstitialAd.load(
      adUnitId: AdManager.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
            FirebaseAnalytics.instance.logEvent(
              name: "ad_loaded",
              parameters: {
                "full_text": "Interstitial Ad Loaded",
              },
            );
          });
        },
        onAdFailedToLoad: (err) {
          FirebaseAnalytics.instance.logEvent(
            name: "ad_loaded",
            parameters: {
              "full_text": "Interstitial Ad Failed to Load",
            },
          );
        },
      ),
    );
    // End :: LoadAd

    // Start :: ProgressController
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {});
      });
    progressController.repeat();
    super.initState();
    // End :: ProgressController

    // Start :: WebViewController
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // _cleanUI();
            progressController.value = progress / 100;
            _interstitialAd?.show();
          },
          onPageStarted: (String url) {
            progressController.value = 0;
          },
          onPageFinished: (String url) {
            progressController.value = 0;
          },
          onWebResourceError: (WebResourceError error) {
            SnackBar(
                content: const Text('Something went wrong!'),
                backgroundColor: Colors.black54,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)));
          },
          onNavigationRequest: (NavigationRequest request) async {
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {},
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message.message),
                backgroundColor: Colors.black54,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    // End :: WebViewController
  }

  // Start :: RemoveHeader&Footer
  // Future<void> _cleanUI() async {
  //   await _controller.runJavaScript(
  //       "javascript:(function() {document.getElementsByClassName('')[0].style.display='none';})");
  // }
  // End :: RemoveHeader&Footer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black87,
          statusBarIconBrightness: Brightness.light,
        ),
        toolbarHeight: 0.1,
      ),
      body: Column(children: [
        if (_bannerAd != null)
          Container(
            height: 0.1,
            color: Colors.black87,
            child: SizedBox(
              height: 60,
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        LinearProgressIndicator(
          value: progressController.value,
          backgroundColor: Colors.black87,
          color: const Color.fromARGB(255, 56, 138, 93),
        ),
        Expanded(
          child: WebViewWidget(controller: _controller),
        ),
        if (_bannerAd != null)
          Container(
            height: 0.1,
            color: Colors.black87,
            child: SizedBox(
              height: 60,
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
      ]),
    );
  }
}
