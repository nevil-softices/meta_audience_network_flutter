import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

enum NativeAdType {
  /// Customizable Native Ad.
  NATIVE_AD,

  /// Customizable Native Banner Ad.
  NATIVE_BANNER_AD,
  //ios Only
  NATIVE_AD_HORIZONTAL,
  NATIVE_AD_VERTICAL,
}

class NativeAdListener {
  final void Function(int code, String message)? onError;
  final void Function()? onLoaded;
  final void Function()? onClicked;
  final void Function()? onLoggingImpression;
  final void Function()? onMediaDownloaded;

  NativeAdListener({
    this.onError,
    this.onLoaded,
    this.onClicked,
    this.onLoggingImpression,
    this.onMediaDownloaded,
  });
}

/// Defines the size of Native Banner Ads. Only three ad sizes are supported.
/// The width is flexible with predefined heights as follow:
///
/// * [HEIGHT_50] (Includes: Icon, Title, Context and CTA button)
/// * [HEIGHT_100] (Includes: Icon, Title, Context and CTA button)
/// * [HEIGHT_120] (Includes: Icon, Title, Context, Description and CTA button)
class NativeBannerAdSize {
  final int? height;

  static const NativeBannerAdSize HEIGHT_50 = NativeBannerAdSize(height: 50);
  static const NativeBannerAdSize HEIGHT_100 = NativeBannerAdSize(height: 100);
  static const NativeBannerAdSize HEIGHT_120 = NativeBannerAdSize(height: 120);

  const NativeBannerAdSize({this.height});
}

class NativeAd extends StatefulWidget {
  static const testPlacementId = 'YOUR_PLACEMENT_ID';

  /// Replace the default one with your placement ID for the release build.
  final String placementId;

  /// Native Ad listener.
  final NativeAdListener? listener;

  /// Choose between [NativeAdType.NATIVE_AD] and
  /// [NativeAdType.NATIVE_BANNER_AD]
  final NativeAdType adType;

  /// If [adType] is [NativeAdType.NATIVE_BANNER_AD] you can choose between
  /// three predefined Ad sizes.
  final NativeBannerAdSize bannerAdSize;

  /// Recommended width is between **280-500** for Native Ads. You can use
  /// [double.infinity] as the width to match the parent widget width.
  final double width;

  /// Recommended width is between **250-500** for Native Ads. Native Banner Ad
  /// height is predefined in [bannerAdSize] and cannot be
  /// changed through this parameter.
  final double height;

  /// This defines the background color of the Native Ad.
  final Color? backgroundColor;

  /// This defines the title text color of the Native Ad.
  final Color? titleColor;

  /// This defines the description text color of the Native Ad.
  final Color? descriptionColor;

  /// This defines the button color of the Native Ad.
  final Color? labelColor;

  /// This defines the button color of the Native Ad.
  final Color? buttonColor;

  /// This defines the button text color of the Native Ad.
  final Color? buttonTitleColor;

  /// This defines the button border color of the Native Ad.
  final Color? buttonBorderColor;

  final bool isMediaCover;

  /// This defines if the ad view to be kept alive.
  final bool keepAlive;

  /// This defines if the ad view should be collapsed while loading
  final bool keepExpandedWhileLoading;

  /// Expand animation duration in milliseconds
  final int expandAnimationDuraion;

  /// This widget can be used to display customizable native ads and native
  /// banner ads.
  NativeAd({
    Key? key,
    this.placementId = NativeAd.testPlacementId,
    this.listener,
    required this.adType,
    this.bannerAdSize = NativeBannerAdSize.HEIGHT_50,
    this.width = double.infinity,
    this.height = 250,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.labelColor,
    this.buttonColor,
    this.buttonTitleColor,
    this.buttonBorderColor,
    this.isMediaCover = false,
    this.keepAlive = false,
    this.keepExpandedWhileLoading = true,
    this.expandAnimationDuraion = 0,
  }) : super(key: key);

  @override
  _NativeAdState createState() => _NativeAdState();
}

class _NativeAdState extends State<NativeAd>
    with AutomaticKeepAliveClientMixin {
  final double containerHeight = Platform.isAndroid ? 1.0 : 0.1;
  bool isAdReady = false;
  @override
  bool get wantKeepAlive => widget.keepAlive;

  String _getChannelRegisterId() {
    String channel = NATIVE_AD_CHANNEL;
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        widget.adType == NativeAdType.NATIVE_BANNER_AD) {
      channel = NATIVE_BANNER_AD_CHANNEL;
    }
    return channel;
  }

  Widget build(BuildContext context) {
    super.build(context);
    double width = widget.width == double.infinity
        ? MediaQuery.of(context).size.width
        : widget.width;
    return AnimatedContainer(
      color: Colors.transparent,
      width: width,
      height: isAdReady || widget.keepExpandedWhileLoading
          ? widget.height
          : containerHeight,
      duration: Duration(milliseconds: widget.expandAnimationDuraion),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            top: isAdReady || widget.keepExpandedWhileLoading
                ? 0
                : -(widget.height - containerHeight),
            child: ConstrainedBox(
              constraints: new BoxConstraints(
                maxHeight: widget.height,
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: buildPlatformView(width),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlatformView(double width) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: width,
        height: widget.adType == NativeAdType.NATIVE_AD ||
                widget.adType == NativeAdType.NATIVE_AD_HORIZONTAL ||
                widget.adType == NativeAdType.NATIVE_AD_VERTICAL
            ? widget.height
            : widget.bannerAdSize.height!.toDouble(),
        child: AndroidView(
          viewType: NATIVE_AD_CHANNEL,
          onPlatformViewCreated: _onNativeAdViewCreated,
          creationParamsCodec: StandardMessageCodec(),
          creationParams: <String, dynamic>{
            "id": widget.placementId,
            "banner_ad":
                widget.adType == NativeAdType.NATIVE_BANNER_AD ? true : false,
            // height param is only for Banner Ads. Native Ad's height is
            // governed by container.
            "height": widget.bannerAdSize.height,
            "bg_color": widget.backgroundColor == null
                ? null
                : _getHexStringFromColor(widget.backgroundColor!),
            "title_color": widget.titleColor == null
                ? null
                : _getHexStringFromColor(widget.titleColor!),
            "desc_color": widget.descriptionColor == null
                ? null
                : _getHexStringFromColor(widget.descriptionColor!),
            "label_color": widget.labelColor == null
                ? null
                : _getHexStringFromColor(widget.labelColor!),
            "button_color": widget.buttonColor == null
                ? null
                : _getHexStringFromColor(widget.buttonColor!),
            "button_title_color": widget.buttonTitleColor == null
                ? null
                : _getHexStringFromColor(widget.buttonTitleColor!),
            "button_border_color": widget.buttonBorderColor == null
                ? null
                : _getHexStringFromColor(widget.buttonBorderColor!),
          },
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        width: width,
        height: widget.adType == NativeAdType.NATIVE_AD
            ? widget.height
            : widget.bannerAdSize.height!.toDouble(),
        child: UiKitView(
          viewType: _getChannelRegisterId(),
          onPlatformViewCreated: _onNativeAdViewCreated,
          creationParamsCodec: StandardMessageCodec(),
          creationParams: <String, dynamic>{
            "id": widget.placementId,
            "ad_type": widget.adType.index,
            "banner_ad":
                widget.adType == NativeAdType.NATIVE_BANNER_AD ? true : false,
            "height": widget.adType == NativeAdType.NATIVE_BANNER_AD
                ? widget.bannerAdSize.height
                : widget.height,
            "bg_color": widget.backgroundColor == null
                ? null
                : _getHexStringFromColor(widget.backgroundColor!),
            "title_color": widget.titleColor == null
                ? null
                : _getHexStringFromColor(widget.titleColor!),
            "desc_color": widget.descriptionColor == null
                ? null
                : _getHexStringFromColor(widget.descriptionColor!),
            "label_color": widget.labelColor == null
                ? null
                : _getHexStringFromColor(widget.labelColor!),
            "button_color": widget.buttonColor == null
                ? null
                : _getHexStringFromColor(widget.buttonColor!),
            "button_title_color": widget.buttonTitleColor == null
                ? null
                : _getHexStringFromColor(widget.buttonTitleColor!),
            "button_border_color": widget.buttonBorderColor == null
                ? null
                : _getHexStringFromColor(widget.buttonBorderColor!),
            "is_media_cover": widget.isMediaCover,
          },
        ),
      );
    } else {
      return Container(
        width: width,
        height: widget.height,
        child: Text("Native Ads for this platform is currently not supported"),
      );
    }
  }

  String _getHexStringFromColor(Color color) =>
      '#${color.value.toRadixString(16)}';

  void _onNativeAdViewCreated(int id) {
    final channel = MethodChannel('${NATIVE_AD_CHANNEL}_$id');

    channel.setMethodCallHandler((MethodCall call) async {
      final args = call.arguments;
      switch (call.method) {
        case ERROR_METHOD:
          final errorCode = args['error_code'];
          final errorMessage = args['error_message'];
          widget.listener?.onError?.call(errorCode ?? 1001, errorMessage ?? "No Fill");
          break;
        case LOADED_METHOD:
          if (!isAdReady) setState(() => isAdReady = true);

          widget.listener?.onLoaded?.call();

          /// ISSUE: Changing height on Ad load causes the ad button to not work
          /*setState(() {
            containerHeight = widget.height;
          });*/
          break;
        // TODO(lslv1243): there was this case that was being called
        //  after ad has been presented, but it was only implemented
        //  on android
        // case LOAD_SUCCESS_METHOD:
        //   if (!mounted) return;
        //   if (!isAdReady) setState(() => isAdReady = true);
        //   break;
        case CLICKED_METHOD:
          widget.listener?.onClicked?.call();
          break;
        case LOGGING_IMPRESSION_METHOD:
          widget.listener?.onLoggingImpression?.call();
          break;
        case MEDIA_DOWNLOADED_METHOD:
          widget.listener?.onMediaDownloaded?.call();
          break;
      }
    });
  }
}
