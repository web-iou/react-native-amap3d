#import "MapUtils.h"
#import <MAMapKit/MAMapKit.h>

@implementation MapUtils

RCT_EXPORT_MODULE();

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(calculateLineDistance:(NSDictionary *)startPoint
                  endPoint:(NSDictionary *)endPoint)
{
  CLLocationCoordinate2D start = CLLocationCoordinate2DMake(
    [startPoint[@"latitude"] doubleValue],
    [startPoint[@"longitude"] doubleValue]
  );

  CLLocationCoordinate2D end = CLLocationCoordinate2DMake(
    [endPoint[@"latitude"] doubleValue],
    [endPoint[@"longitude"] doubleValue]
  );

  double distance = MAMetersBetweenMapPoints(
    MAMapPointForCoordinate(start),
    MAMapPointForCoordinate(end)
  );

  return @(distance);
}

@end
