import 'interstitial_ad_platform_interface.dart';

class InterstitialAdListener {
  final void Function(int code, String message)? onError;
  final void Function()? onDisplayed;
  final void Function()? onDismissed;
  final void Function()? onLoaded;
  final void Function()? onClicked;
  final void Function()? onLoggingImpression;

  InterstitialAdListener({
    this.onDisplayed,
    this.onDismissed,
    this.onError,
    this.onLoaded,
    this.onClicked,
    this.onLoggingImpression,
  });
}

class InterstitialAd {
  static const testPlacementId = 'YOUR_PLACEMENT_ID';
  static var _lastId = -1;

  var _loaded = false;
  var _shown = false;
  var _destroyed = false;
  final int _id;
  final String placementId;
  InterstitialAdListener? listener;

  InterstitialAd._(this._id, this.placementId);

  factory InterstitialAd(String placementId) {
    final id = ++_lastId;
    return InterstitialAd._(id, placementId);
  }

  /// don't forget to destroy after using it
  Future<void> load() async {
    assert(!_loaded);
    if (_loaded) return;
    _loaded = true;

    await InterstitialAdPlatformInterface.loadInterstitialAd(
      _id,
      placementId: placementId,
      listener: (result, args) {
        switch (result) {
          case InterstitialAdPlatformInterfaceResult.DISPLAYED:
            listener?.onDisplayed?.call();
            break;
          case InterstitialAdPlatformInterfaceResult.DISMISSED:
            listener?.onDismissed?.call();
            break;
          case InterstitialAdPlatformInterfaceResult.ERROR:
            final errorCode = args['error_code'];
            final errorMessage = args['error_message'];
            listener?.onError
                ?.call(errorCode ?? 1001, errorMessage ?? "No Fill");
            break;
          case InterstitialAdPlatformInterfaceResult.LOADED:
            listener?.onLoaded?.call();
            break;
          case InterstitialAdPlatformInterfaceResult.CLICKED:
            listener?.onClicked?.call();
            break;
          case InterstitialAdPlatformInterfaceResult.LOGGING_IMPRESSION:
            listener?.onLoggingImpression?.call();
            break;
        }
      },
    );
  }

  Future<void> show() async {
    assert(!_shown);
    if (_shown) return;
    _shown = true;

    await InterstitialAdPlatformInterface.showInterstitialAd(_id);
  }

  Future<void> destroy() async {
    assert(!_destroyed);
    if (_destroyed) return;
    _destroyed = true;

    await InterstitialAdPlatformInterface.destroyInterstitialAd(_id);
  }
}
