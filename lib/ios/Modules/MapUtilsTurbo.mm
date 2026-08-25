#import "MapUtils.h"

#import <MAMapKit/MAMapKit.h>
using namespace facebook::react;

@implementation MapUtils

RCT_EXPORT_MODULE(AMapUtils)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (NSNumber *)calculateLineDistance:(JS::NativeAMapUtils::LatLng &)startPoint
                           endPoint:(JS::NativeAMapUtils::LatLng &)endPoint
{
  CLLocationCoordinate2D start = CLLocationCoordinate2DMake(
      startPoint.latitude(), startPoint.longitude());
  CLLocationCoordinate2D end = CLLocationCoordinate2DMake(
      endPoint.latitude(), endPoint.longitude());
  return @(MAMetersBetweenMapPoints(
      MAMapPointForCoordinate(start), MAMapPointForCoordinate(end)));
}

- (std::shared_ptr<TurboModule>)getTurboModule:(ObjCTurboModule::InitParams const &)params
{
  return std::make_shared<NativeAMapUtilsSpecJSI>(params);
}

@end
