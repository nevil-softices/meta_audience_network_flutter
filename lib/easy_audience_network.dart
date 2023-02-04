/// Facebook Audience Network plugin for Flutter applications.
///
/// This library uses native API of [Facebook Audience Network](https://developers.facebook.com/docs/audience-network)
/// to provide functionality for Flutter applications.
///
/// Currently only Android platform is supported.
library easy_audience_network;

import 'package:flutter/services.dart';

import 'constants.dart';

export 'ad/banner_ad.dart';
export 'ad/interstitial_ad.dart';
export 'ad/native_ad.dart';
export 'ad/rewarded_ad.dart';

/// All non-widget functions such as initialization, loading interstitial,
/// in-stream and reward video ads are enclosed in this class.
///
/// Initialize the Facebook Audience Network by calling the static [init]
/// function.
class EasyAudienceNetwork {
  static const _channel = const MethodChannel(MAIN_CHANNEL);

  /// Initializes the Facebook Audience Network. [testingId] can be used to
  /// obtain test Ads. [testMode] can be used to obtain test Ads as well,
  /// it is more useful on iOS where testingId keeps changing.
  ///
  /// [testingId] can be obtained by running the app once without the testingId.
  /// Check the log to obtain the [testingId] for your device.
  static Future<bool?> init({
    String? testingId,
    bool testMode = false,
    bool iOSAdvertiserTrackingEnabled = false,
  }) async {
    Map<String, dynamic> initValues = {
      "testingId": testingId,
      "iOSAdvertiserTrackingEnabled": iOSAdvertiserTrackingEnabled,
      "testMode": testMode,
    };

    try {
      final result = await _channel.invokeMethod(INIT_METHOD, initValues);
      return result;
    } on PlatformException {
      return false;
    }
  }
}
