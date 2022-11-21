#import "MsalFlutterPlugin.h"
#import <msal_flutter/msal_flutter-Swift.h>

@implementation MsalFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMsalFlutterPluginV2 registerWithRegistrar:registrar];
}
@end
