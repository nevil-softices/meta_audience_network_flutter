#import "FacebookAudienceNetworkPlugin.h"
#import <easy_audience_network/easy_audience_network-Swift.h>
// #import "audience_network-Swift.h"

@implementation FacebookAudienceNetworkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [FANPlugin registerWithRegistrar:registrar];
}
@end
