#import <MAMapKit/MAMapKit.h>
#import <ReactCodegen/RNAmap3dSpec/RNAmap3dSpec.h>

using namespace facebook::react;

@interface AMapSdkTurbo : NativeAMapSdkSpecBase <NativeAMapSdkSpec>
@end

@implementation AMapSdkTurbo

RCT_EXPORT_MODULE(AMapSdk)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (void)initSDK:(NSString *)apiKey
{
  [AMapServices sharedServices].apiKey = apiKey;
  [MAMapView updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
  [MAMapView
      updatePrivacyShow:AMapPrivacyShowStatusDidShow
            privacyInfo:AMapPrivacyInfoStatusDidContain];
}

- (void)getVersion:(RCTPromiseResolveBlock)resolve
            reject:(__unused RCTPromiseRejectBlock)reject
{
  resolve(@"8.0.1");
}

- (std::shared_ptr<TurboModule>)getTurboModule:(ObjCTurboModule::InitParams const &)params
{
  return std::make_shared<NativeAMapSdkSpecJSI>(params);
}

@end
