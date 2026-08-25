#import <React/RCTViewComponentView.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMapBaseComponentView : RCTViewComponentView
@property (nonatomic, strong, readonly) UIView *nativeView;
- (instancetype)initWithNativeClassName:(NSString *)className;
@end

@interface AMapViewComponentView : AMapBaseComponentView
@end

@interface AMapMarkerComponentView : AMapBaseComponentView
@end

@interface AMapCircleComponentView : AMapBaseComponentView
@end

@interface AMapPolylineComponentView : AMapBaseComponentView
@end

@interface AMapPolygonComponentView : AMapBaseComponentView
@end

@interface AMapMultiPointComponentView : AMapBaseComponentView
@end

@interface AMapHeatMapComponentView : AMapBaseComponentView
@end

NS_ASSUME_NONNULL_END
