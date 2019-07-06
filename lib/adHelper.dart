import 'package:firebase_admob/firebase_admob.dart';
import 'dart:io' show Platform;

class AdHelper {
  static InterstitialAd loaded;
  static MobileAdTargetingInfo targetingInfo;
  static String appId;
  static String interstitialAdUnitId;
  static String bannerAdUnitId;

  static Function adOpenedFunction = () {};
  static Function adClosedFunction = () {};

  static List<BannerAd> allBannerAds = [];

  static bool hideBanners = false;

  static Future<bool> init() async {
    //iPhone
    if (Platform.isIOS) {
      appId = "OMITTED";
      interstitialAdUnitId = "OMITTED";
      bannerAdUnitId = "OMITTED";
    }
    //Android
    else {
      appId = "OMITTED";
      interstitialAdUnitId = "OMITTED";
      bannerAdUnitId = "OMITTED";
    }

    await FirebaseAdMob.instance.initialize(appId: appId);

    targetingInfo = MobileAdTargetingInfo(
      childDirected: false,
    );
    return true;
  }

  static Future loadAd() async {
    loaded = InterstitialAd(
      adUnitId: interstitialAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.opened) adOpenedFunction();
        if (event == MobileAdEvent.closed) adClosedFunction();
      },
    );
    await loaded.load();
  }

  static BannerAd loadBanner() {
    return BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.smartBanner,
        targetingInfo: targetingInfo,
        listener: (event) {
          if (!hideBanners && event == MobileAdEvent.impression) hideBanner();
        });
  }

  static Future<bool> showAd() async {
    bool result = false;
    if (loaded != null && await loaded.isLoaded()) {
      loaded.show();
      result = true;
    }
    await loadAd();
    return result;
  }

  static Future<bool> showBanner() async {
    hideBanners = false;
    BannerAd ad = loadBanner();
    allBannerAds.add(ad);
    if (hideBanners) return false;
    await ad.load();
    await ad.show(anchorType: AnchorType.bottom, anchorOffset: 10).then((_) {
      if (!allBannerAds.contains(ad) || hideBanners) ad.dispose();
    });
    if (hideBanners) hideBanner();

    return !hideBanners;
  }

  static hideBanner() async {
    hideBanners = true;
    while (allBannerAds.isNotEmpty) {
      BannerAd ad = allBannerAds[0];
      if (await ad.isLoaded()) {
        ad.dispose();
        allBannerAds.remove(ad);
      }
    }
  }
}
