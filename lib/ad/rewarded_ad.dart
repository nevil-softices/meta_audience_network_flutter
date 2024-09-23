import 'rewarded_ad_platform_interface.dart';

class RewardedAdListener {
  final void Function(int code, String message)? onError;
  final void Function()? onVideoComplete;
  final void Function()? onVideoClosed;
  final void Function()? onLoaded;
  final void Function()? onClicked;
  final void Function()? onLoggingImpression;

  RewardedAdListener({
    this.onVideoComplete,
    this.onVideoClosed,
    this.onError,
    this.onLoaded,
    this.onClicked,
    this.onLoggingImpression,
  });
}

class RewardedAd {
  static const testPlacementId = 'YOUR_PLACEMENT_ID';
  static var _lastId = -1;

  var _loaded = false;
  var _shown = false;
  var _destroyed = false;
  final int _id;
  final String placementId;
  final String? userId;
  RewardedAdListener? listener;

  RewardedAd._(this._id, this.placementId, this.userId);

  factory RewardedAd(String placementId, {String? userId}) {
    final id = ++_lastId;
    return RewardedAd._(id, placementId, userId);
  }

  /// don't forget to destroy after using it
  Future<void> load() async {
    assert(!_loaded);
    if (_loaded) return;
    _loaded = true;

    await RewardedAdPlatformInterface.loadRewardedVideoAd(
      _id,
      placementId: placementId,
      userId: userId,
      listener: (result, args) {
        switch (result) {
          case RewardedAdPlatformInterfaceResult.VIDEO_COMPLETE:
            listener?.onVideoComplete?.call();
            break;
          case RewardedAdPlatformInterfaceResult.VIDEO_CLOSED:
            listener?.onVideoClosed?.call();
            break;
          case RewardedAdPlatformInterfaceResult.ERROR:
            final errorCode = args['error_code'];
            final errorMessage = args['error_message'];
            listener?.onError?.call(errorCode ?? 1001, errorMessage ?? "No Fill");
            break;
          case RewardedAdPlatformInterfaceResult.LOADED:
            listener?.onLoaded?.call();
            break;
          case RewardedAdPlatformInterfaceResult.CLICKED:
            listener?.onClicked?.call();
            break;
          case RewardedAdPlatformInterfaceResult.LOGGING_IMPRESSION:
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

    await RewardedAdPlatformInterface.showRewardedVideoAd(_id);
  }

  Future<void> destroy() async {
    assert(!_destroyed);
    if (_destroyed) return;
    _destroyed = true;

    await RewardedAdPlatformInterface.destroyRewardedVideoAd(_id);
  }
}
