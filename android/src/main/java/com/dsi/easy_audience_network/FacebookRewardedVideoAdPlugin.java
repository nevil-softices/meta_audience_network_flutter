package com.dsi.easy_audience_network;

import android.content.Context;
import android.os.Handler;
import android.util.Log;

import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.RewardData;
import com.facebook.ads.RewardedVideoAd;
import com.facebook.ads.RewardedVideoAdListener;

import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class FacebookRewardedVideoAdPlugin implements MethodChannel.MethodCallHandler {
    private HashMap<Integer, RewardedVideoAd> adsById = new HashMap<>();
    private HashMap<RewardedVideoAd, Integer> idsByAd = new HashMap<>();

    private Context context;
    private MethodChannel channel;

    private Handler _delayHandler;

    FacebookRewardedVideoAdPlugin(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;

        _delayHandler = new Handler();
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

        switch (methodCall.method) {
            case FacebookConstants.SHOW_REWARDED_VIDEO_METHOD:
                result.success(showAd((HashMap) methodCall.arguments));
                break;
            case FacebookConstants.LOAD_REWARDED_VIDEO_METHOD:
                result.success(loadAd((HashMap) methodCall.arguments));
                break;
            case FacebookConstants.DESTROY_REWARDED_VIDEO_METHOD:
                result.success(destroyAd((HashMap) methodCall.arguments));
                break;
            default:
                result.notImplemented();
        }
    }

    private boolean loadAd(HashMap args) {
        final int id = (int) args.get("id");
        final String placementId = (String) args.get("placementId");
        final String userId = (String) args.get("userId");

        RewardedVideoAd rewardedVideoAd = adsById.get(id);
        if (rewardedVideoAd == null) {
            rewardedVideoAd = new RewardedVideoAd(context, placementId);
            adsById.put(id, rewardedVideoAd);
            idsByAd.put(rewardedVideoAd, id);
        }
        try {
            final RewardData rewardData = new RewardData(userId, null);
            if (!rewardedVideoAd.isAdLoaded()) {
                final FacebookRewardedVideoAdPlugin self = this;
                final RewardedVideoAd capturedAd = rewardedVideoAd;
                RewardedVideoAd.RewardedVideoLoadAdConfig loadAdConfig = rewardedVideoAd
                        .buildLoadAdConfig()
                        .withRewardData(rewardData)
                        .withAdListener(new RewardedVideoAdListener() {
                            @Override
                            public void onRewardedVideoCompleted() {
                                self.onRewardedVideoCompleted(capturedAd);
                            }

                            @Override
                            public void onRewardedVideoClosed() {
                                self.onRewardedVideoClosed(capturedAd);
                            }

                            @Override
                            public void onError(Ad ad, AdError adError) {
                                self.onError(ad, adError);
                            }

                            @Override
                            public void onAdLoaded(Ad ad) {
                                self.onAdLoaded(ad);
                            }

                            @Override
                            public void onAdClicked(Ad ad) {
                                self.onAdClicked(ad);
                            }

                            @Override
                            public void onLoggingImpression(Ad ad) {
                                self.onLoggingImpression(ad);
                            }
                        })
                        .build();

                rewardedVideoAd.loadAd(loadAdConfig);
            }
        } catch (Exception e) {
            Log.e("RewardedVideoAdError", e.getMessage());
            return false;
        }

        return true;
    }

    private boolean showAd(HashMap args) {
        final int id = (int) args.get("id");
        final int delay = (int) args.get("delay");
        final RewardedVideoAd rewardedVideoAd = adsById.get(id);
        
        if (rewardedVideoAd == null || !rewardedVideoAd.isAdLoaded())
            return false;

        if (rewardedVideoAd.isAdInvalidated())
            return false;

        if (delay <= 0) {
            RewardedVideoAd.RewardedVideoShowAdConfig showAdConfig = rewardedVideoAd.buildShowAdConfig().build();

            rewardedVideoAd.show(showAdConfig);
        } else {
            _delayHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    if (rewardedVideoAd == null || !rewardedVideoAd.isAdLoaded())
                        return;

                    if (rewardedVideoAd.isAdInvalidated())
                        return;
                    RewardedVideoAd.RewardedVideoShowAdConfig showAdConfig = rewardedVideoAd.buildShowAdConfig().build();

                    rewardedVideoAd.show(showAdConfig);
                }
            }, delay);
        }
        return true;
    }

    private boolean destroyAd(HashMap args) {
        final int id = (int) args.get("id");
        final RewardedVideoAd rewardedVideoAd = adsById.get(id);

        if (rewardedVideoAd == null)
            return false;

        rewardedVideoAd.destroy();
        adsById.remove(id);
        idsByAd.remove(rewardedVideoAd);
        return true;
    }

    // MARK: delegate methods

    private void onError(Ad ad, AdError adError) {
        final int id = idsByAd.get(ad);

        HashMap<String, Object> args = new HashMap<>();
        args.put("id", id);
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());
        args.put("error_code", adError.getErrorCode());
        args.put("error_message", adError.getErrorMessage());

        channel.invokeMethod(FacebookConstants.ERROR_METHOD, args);
    }

    private void onAdLoaded(Ad ad) {
        final int id = idsByAd.get(ad);

        HashMap<String, Object> args = new HashMap<>();
        args.put("id", id);
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.LOADED_METHOD, args);
    }

    private void onAdClicked(Ad ad) {
        final int id = idsByAd.get(ad);

        HashMap<String, Object> args = new HashMap<>();
        args.put("id", id);
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.CLICKED_METHOD, args);
    }

    private void onLoggingImpression(Ad ad) {
        final int id = idsByAd.get(ad);

        HashMap<String, Object> args = new HashMap<>();
        args.put("id", id);
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.LOGGING_IMPRESSION_METHOD, args);
    }

    private void onRewardedVideoCompleted(RewardedVideoAd ad) {
        final int id = idsByAd.get(ad);

        HashMap<String, Object> args = new HashMap<>();
        args.put("id", id);
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.REWARDED_VIDEO_COMPLETE_METHOD, args);
    }

    private void onRewardedVideoClosed(RewardedVideoAd ad) {
        final int id = idsByAd.get(ad);

        HashMap<String, Object> args = new HashMap<>();
        args.put("id", id);
        args.put("placement_id", ad.getPlacementId());
        args.put("invalidated", ad.isAdInvalidated());

        channel.invokeMethod(FacebookConstants.REWARDED_VIDEO_CLOSED_METHOD, args);
    }
}
