#import "AMapFabricComponents.h"

#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/RNAmap3dSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNAmap3dSpec/EventEmitters.h>
#import <react/renderer/components/RNAmap3dSpec/Props.h>
#import <react/renderer/components/RNAmap3dSpec/RCTComponentViewHelpers.h>
#import <react/renderer/components/view/ViewProps.h>

#import <CoreLocation/CoreLocation.h>
#import <objc/message.h>

using namespace facebook::react;

static NSDictionary *AMapParseJSON(NSString *json)
{
  if (![json isKindOfClass:NSString.class]) {
    return nil;
  }
  NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
  id value = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
  return [value isKindOfClass:NSDictionary.class] ? value : nil;
}

template <typename T>
static NSArray *AMapCoordinateArray(std::vector<T> const &coordinates)
{
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:coordinates.size()];
  for (auto const &coordinate : coordinates) {
    [result addObject:@{@"latitude" : @(coordinate.latitude), @"longitude" : @(coordinate.longitude)}];
  }
  return result;
}

template <typename T>
static NSDictionary *AMapImageDictionary(T const &source)
{
  if (source.uri.empty()) {
    return nil;
  }
  return @{
    @"uri" : [NSString stringWithUTF8String:source.uri.c_str()],
    @"width" : @(source.width),
    @"height" : @(source.height),
    @"scale" : @(source.scale),
  };
}

@interface AMapBaseComponentView ()
@property (nonatomic, strong, readwrite) UIView *nativeView;
@end

@implementation AMapBaseComponentView

- (instancetype)initWithNativeClassName:(NSString *)className
{
  if ((self = [super init])) {
    Class viewClass = NSClassFromString(className);
    NSAssert(viewClass, @"Missing Swift class %@", className);
    _nativeView = [viewClass new];
    self.contentView = _nativeView;
  }
  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  // zIndex comes from View style (BaseViewProps), not a custom Codegen prop.
  auto const &viewProps = *std::static_pointer_cast<ViewProps const>(props);
  if (viewProps.zIndex.has_value() && [_nativeView respondsToSelector:@selector(setZIndex:)]) {
    [_nativeView setValue:@(viewProps.zIndex.value()) forKey:@"zIndex"];
  }
  [super updateProps:props oldProps:oldProps];
}

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)child index:(NSInteger)index
{
  UIView *nativeChild = [child isKindOfClass:AMapBaseComponentView.class]
      ? ((AMapBaseComponentView *)child).nativeView
      : child;
  if ([_nativeView respondsToSelector:@selector(mountFabricSubview:)]) {
    ((void (*)(id, SEL, UIView *))objc_msgSend)(
        _nativeView, @selector(mountFabricSubview:), nativeChild);
  }
  [_nativeView insertSubview:nativeChild atIndex:index];
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)child index:(NSInteger)index
{
  UIView *nativeChild = [child isKindOfClass:AMapBaseComponentView.class]
      ? ((AMapBaseComponentView *)child).nativeView
      : child;
  if ([_nativeView respondsToSelector:@selector(unmountFabricSubview:)]) {
    ((void (*)(id, SEL, UIView *))objc_msgSend)(
        _nativeView, @selector(unmountFabricSubview:), nativeChild);
  }
  [nativeChild removeFromSuperview];
}

@end

@interface AMapViewComponentView () <RCTAMapViewViewProtocol>
@end

@implementation AMapViewComponentView

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<AMapViewComponentDescriptor>();
}

- (instancetype)init
{
  if ((self = [super initWithNativeClassName:@"AMapNativeMapView"])) {
    static const auto defaultProps = std::make_shared<const AMapViewProps>();
    _props = defaultProps;
  }
  return self;
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];
  // Fabric 会复用 ComponentView；不重置则 initialCameraPosition / 定位像“有缓存”
  if ([self.nativeView respondsToSelector:@selector(resetForRecycle)]) {
    ((void (*)(id, SEL))objc_msgSend)(self.nativeView, @selector(resetForRecycle));
  }
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  auto const &value = *std::static_pointer_cast<AMapViewProps const>(props);
  NSDictionary *camera = @{
    @"target" : @{
      @"latitude" : @(value.initialCameraPosition.target.latitude),
      @"longitude" : @(value.initialCameraPosition.target.longitude),
    },
    @"zoom" : @(value.initialCameraPosition.zoom),
    @"bearing" : @(value.initialCameraPosition.bearing),
    @"tilt" : @(value.initialCameraPosition.tilt),
  };
  if (value.initialCameraPosition.zoom > 0 ||
      value.initialCameraPosition.target.latitude != 0 ||
      value.initialCameraPosition.target.longitude != 0) {
    ((void (*)(id, SEL, NSDictionary *))objc_msgSend)(
        self.nativeView, @selector(setInitialCameraPosition:), camera);
  }
  [self.nativeView setValue:@(value.mapType) forKey:@"mapType"];
  [self.nativeView setValue:@(value.myLocationEnabled) forKey:@"showsUserLocation"];
  [self.nativeView setValue:@(value.indoorViewEnabled) forKey:@"showsIndoorMap"];
  [self.nativeView setValue:@(value.buildingsEnabled) forKey:@"showsBuildings"];
  [self.nativeView setValue:@(value.labelsEnabled) forKey:@"showsLabels"];
  [self.nativeView setValue:@(value.compassEnabled) forKey:@"showsCompass"];
  [self.nativeView setValue:@(value.scaleControlsEnabled) forKey:@"showsScale"];
  [self.nativeView setValue:@(value.trafficEnabled) forKey:@"showTraffic"];
  [self.nativeView setValue:@(value.zoomGesturesEnabled) forKey:@"zoomEnabled"];
  [self.nativeView setValue:@(value.scrollGesturesEnabled) forKey:@"scrollEnabled"];
  [self.nativeView setValue:@(value.rotateGesturesEnabled) forKey:@"rotateEnabled"];
  [self.nativeView setValue:@(value.tiltGesturesEnabled) forKey:@"rotateCameraEnabled"];
  // Codegen 未传时 min/maxZoom 为 0，写入会锁死缩放；仅在显式 >0 时应用
  if (value.minZoom > 0) {
    [self.nativeView setValue:@(value.minZoom) forKey:@"minZoomLevel"];
  }
  if (value.maxZoom > 0) {
    [self.nativeView setValue:@(value.maxZoom) forKey:@"maxZoomLevel"];
  }
  if (value.distanceFilter > 0) {
    [self.nativeView setValue:@(value.distanceFilter) forKey:@"distanceFilter"];
  }
  if (value.headingFilter > 0) {
    [self.nativeView setValue:@(value.headingFilter) forKey:@"headingFilter"];
  }
  [super updateProps:props oldProps:oldProps];
}

- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter
{
  [super updateEventEmitter:eventEmitter];
  __weak AMapViewComponentView *weakSelf = self;
  [self.nativeView setValue:^(NSDictionary *body) {
    AMapViewComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapViewEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    emitter->onPress({[body[@"latitude"] doubleValue], [body[@"longitude"] doubleValue]});
  } forKey:@"onPress"];
  [self.nativeView setValue:^(NSDictionary *body) {
    AMapViewComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapViewEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    auto position = body[@"position"];
    emitter->onPressPoi({
      [body[@"id"] UTF8String],
      [body[@"name"] UTF8String],
      {[position[@"latitude"] doubleValue], [position[@"longitude"] doubleValue]},
    });
  } forKey:@"onPressPoi"];
  [self.nativeView setValue:^(NSDictionary *body) {
    AMapViewComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapViewEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    emitter->onLongPress({[body[@"latitude"] doubleValue], [body[@"longitude"] doubleValue]});
  } forKey:@"onLongPress"];
  void (^cameraHandler)(NSDictionary *, BOOL) = ^(NSDictionary *body, BOOL idle) {
    AMapViewComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapViewEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    NSDictionary *camera = body[@"cameraPosition"];
    NSDictionary *target = camera[@"target"];
    NSDictionary *bounds = body[@"latLngBounds"];
    NSDictionary *southwest = bounds[@"southwest"];
    NSDictionary *northeast = bounds[@"northeast"];
    if (idle) {
      emitter->onCameraIdle({
        {{[target[@"latitude"] doubleValue], [target[@"longitude"] doubleValue]},
         [camera[@"zoom"] doubleValue], [camera[@"bearing"] doubleValue], [camera[@"tilt"] doubleValue]},
        {{[southwest[@"latitude"] doubleValue], [southwest[@"longitude"] doubleValue]},
         {[northeast[@"latitude"] doubleValue], [northeast[@"longitude"] doubleValue]}},
      });
    } else {
      emitter->onCameraMove({
        {{[target[@"latitude"] doubleValue], [target[@"longitude"] doubleValue]},
         [camera[@"zoom"] doubleValue], [camera[@"bearing"] doubleValue], [camera[@"tilt"] doubleValue]},
        {{[southwest[@"latitude"] doubleValue], [southwest[@"longitude"] doubleValue]},
         {[northeast[@"latitude"] doubleValue], [northeast[@"longitude"] doubleValue]}},
      });
    }
  };
  [self.nativeView setValue:^(NSDictionary *body) { cameraHandler(body, NO); } forKey:@"onCameraMove"];
  [self.nativeView setValue:^(NSDictionary *body) { cameraHandler(body, YES); } forKey:@"onCameraIdle"];
  [self.nativeView setValue:^(__unused NSDictionary *body) {
    AMapViewComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapViewEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    emitter->onLoad({});
  } forKey:@"onLoad"];
  [self.nativeView setValue:^(NSDictionary *body) {
    AMapViewComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapViewEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    // OnLocation = { timestamp, coords: { lat, lng, accuracy, heading, altitude, speed } }
    NSDictionary *coords = [body[@"coords"] isKindOfClass:NSDictionary.class] ? body[@"coords"] : body;
    emitter->onLocation({
      [body[@"timestamp"] doubleValue],
      {
        [coords[@"latitude"] doubleValue],
        [coords[@"longitude"] doubleValue],
        [coords[@"accuracy"] doubleValue],
        [coords[@"heading"] doubleValue],
        [coords[@"altitude"] doubleValue],
        [coords[@"speed"] doubleValue],
      },
    });
  } forKey:@"onLocation"];
  [self.nativeView setValue:^(NSDictionary *body) {
    AMapViewComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapViewEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    NSDictionary *data = body[@"data"];
    emitter->onCallback({
      [body[@"id"] doubleValue],
      {[data[@"latitude"] doubleValue], [data[@"longitude"] doubleValue]},
    });
  } forKey:@"onCallback"];
}

- (void)moveCamera:(NSString *)cameraPosition duration:(double)duration
{
  NSDictionary *camera = AMapParseJSON(cameraPosition);
  if (camera) {
    ((void (*)(id, SEL, NSDictionary *, NSInteger))objc_msgSend)(
        self.nativeView, @selector(moveCameraWithPosition:duration:), camera, (NSInteger)duration);
  }
}

- (void)call:(double)identifier name:(NSString *)name args:(NSString *)args
{
  NSDictionary *arguments = AMapParseJSON(args);
  if (arguments) {
    ((void (*)(id, SEL, double, NSString *, NSDictionary *))objc_msgSend)(
        self.nativeView, @selector(callWithId:name:args:), identifier, name, arguments);
  }
}

- (void)handleCommand:(NSString const *)commandName args:(NSArray const *)args
{
  RCTAMapViewHandleCommand(self, commandName, args);
}

@end

@interface AMapMarkerComponentView () <RCTAMapMarkerViewProtocol>
@end

@implementation AMapMarkerComponentView

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<AMapMarkerComponentDescriptor>();
}

- (instancetype)init
{
  if ((self = [super initWithNativeClassName:@"AMapNativeMarker"])) {
    static const auto defaultProps = std::make_shared<const AMapMarkerProps>();
    _props = defaultProps;
  }
  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  auto const &value = *std::static_pointer_cast<AMapMarkerProps const>(props);
  CLLocationCoordinate2D coordinate =
      CLLocationCoordinate2DMake(value.latLng.latitude, value.latLng.longitude);
  CGPoint offset = CGPointMake(value.centerOffset.x, value.centerOffset.y);
  ((void (*)(id, SEL, CLLocationCoordinate2D))objc_msgSend)(
      self.nativeView, @selector(setLatLng:), coordinate);
  ((void (*)(id, SEL, CGPoint))objc_msgSend)(
      self.nativeView, @selector(setCenterOffset:), offset);
  ((void (*)(id, SEL, NSDictionary *))objc_msgSend)(
      self.nativeView, @selector(setIcon:), AMapImageDictionary(value.icon));
  [self.nativeView setValue:@(value.draggable) forKey:@"draggable"];
  [super updateProps:props oldProps:oldProps];
}

- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter
{
  [super updateEventEmitter:eventEmitter];
  __weak AMapMarkerComponentView *weakSelf = self;
  [self.nativeView setValue:^(__unused NSDictionary *body) {
    AMapMarkerComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapMarkerEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    emitter->onPress({});
  } forKey:@"onPress"];
  [self.nativeView setValue:^(__unused NSDictionary *body) {
    AMapMarkerComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapMarkerEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    emitter->onDragStart({});
  } forKey:@"onDragStart"];
  [self.nativeView setValue:^(__unused NSDictionary *body) {
    AMapMarkerComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapMarkerEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    emitter->onDrag({});
  } forKey:@"onDrag"];
  [self.nativeView setValue:^(NSDictionary *body) {
    AMapMarkerComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapMarkerEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    emitter->onDragEnd({[body[@"latitude"] doubleValue], [body[@"longitude"] doubleValue]});
  } forKey:@"onDragEnd"];
}

- (void)update
{
  ((void (*)(id, SEL))objc_msgSend)(self.nativeView, @selector(update));
}

- (void)handleCommand:(NSString const *)commandName args:(NSArray const *)args
{
  RCTAMapMarkerHandleCommand(self, commandName, args);
}

@end

#define AMAP_SIMPLE_BEGIN(CLASS, NATIVE, PROPS, DESCRIPTOR)                               \
  @implementation CLASS                                                                    \
  + (ComponentDescriptorProvider)componentDescriptorProvider                               \
  {                                                                                         \
    return concreteComponentDescriptorProvider<DESCRIPTOR>();                              \
  }                                                                                         \
  - (instancetype)init                                                                      \
  {                                                                                         \
    if ((self = [super initWithNativeClassName:NATIVE])) {                                  \
      static const auto defaultProps = std::make_shared<const PROPS>();                     \
      _props = defaultProps;                                                                 \
    }                                                                                       \
    return self;                                                                             \
  }

AMAP_SIMPLE_BEGIN(AMapCircleComponentView, @"AMapNativeCircle", AMapCircleProps, AMapCircleComponentDescriptor)
- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  auto const &value = *std::static_pointer_cast<AMapCircleProps const>(props);
  CLLocationCoordinate2D center = CLLocationCoordinate2DMake(value.center.latitude, value.center.longitude);
  ((void (*)(id, SEL, CLLocationCoordinate2D))objc_msgSend)(self.nativeView, @selector(setCircleCenter:), center);
  [self.nativeView setValue:@(value.radius) forKey:@"radius"];
  [self.nativeView setValue:@(value.strokeWidth) forKey:@"strokeWidth"];
  [self.nativeView setValue:RCTUIColorFromSharedColor(value.strokeColor) forKey:@"strokeColor"];
  [self.nativeView setValue:RCTUIColorFromSharedColor(value.fillColor) forKey:@"fillColor"];
  [super updateProps:props oldProps:oldProps];
}
@end

AMAP_SIMPLE_BEGIN(AMapPolylineComponentView, @"AMapNativePolyline", AMapPolylineProps, AMapPolylineComponentDescriptor)
- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  auto const &value = *std::static_pointer_cast<AMapPolylineProps const>(props);
  ((void (*)(id, SEL, NSArray *))objc_msgSend)(self.nativeView, @selector(setPoints:), AMapCoordinateArray(value.points));
  [self.nativeView setValue:@(value.width) forKey:@"width"];
  [self.nativeView setValue:RCTUIColorFromSharedColor(value.color) forKey:@"color"];
  [self.nativeView setValue:@(value.gradient) forKey:@"gradient"];
  [self.nativeView setValue:@(value.dotted || value.dashed) forKey:@"dotted"];
  NSMutableArray *colors = [NSMutableArray arrayWithCapacity:value.colors.size()];
  for (auto const &color : value.colors) [colors addObject:RCTUIColorFromSharedColor(color)];
  [self.nativeView setValue:colors forKey:@"colors"];
  [super updateProps:props oldProps:oldProps];
}
@end

AMAP_SIMPLE_BEGIN(AMapPolygonComponentView, @"AMapNativePolygon", AMapPolygonProps, AMapPolygonComponentDescriptor)
- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  auto const &value = *std::static_pointer_cast<AMapPolygonProps const>(props);
  ((void (*)(id, SEL, NSArray *))objc_msgSend)(self.nativeView, @selector(setPoints:), AMapCoordinateArray(value.points));
  [self.nativeView setValue:@(value.strokeWidth) forKey:@"strokeWidth"];
  [self.nativeView setValue:RCTUIColorFromSharedColor(value.strokeColor) forKey:@"strokeColor"];
  [self.nativeView setValue:RCTUIColorFromSharedColor(value.fillColor) forKey:@"fillColor"];
  [super updateProps:props oldProps:oldProps];
}
@end

AMAP_SIMPLE_BEGIN(AMapMultiPointComponentView, @"AMapNativeMultiPoint", AMapMultiPointProps, AMapMultiPointComponentDescriptor)
- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  auto const &value = *std::static_pointer_cast<AMapMultiPointProps const>(props);
  ((void (*)(id, SEL, NSArray *))objc_msgSend)(self.nativeView, @selector(setItems:), AMapCoordinateArray(value.items));
  ((void (*)(id, SEL, NSDictionary *))objc_msgSend)(self.nativeView, @selector(setIcon:), AMapImageDictionary(value.icon));
  [super updateProps:props oldProps:oldProps];
}
- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter
{
  [super updateEventEmitter:eventEmitter];
  __weak AMapMultiPointComponentView *weakSelf = self;
  [self.nativeView setValue:^(NSDictionary *body) {
    AMapMultiPointComponentView *strongSelf = weakSelf;
    if (strongSelf == nil) {
      return;
    }
    auto emitter = std::static_pointer_cast<AMapMultiPointEventEmitter const>(strongSelf->_eventEmitter);
    if (!emitter) {
      return;
    }
    emitter->onPress({[body[@"index"] intValue]});
  } forKey:@"onPress"];
}
@end

AMAP_SIMPLE_BEGIN(AMapHeatMapComponentView, @"AMapNativeHeatMap", AMapHeatMapProps, AMapHeatMapComponentDescriptor)
- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  auto const &value = *std::static_pointer_cast<AMapHeatMapProps const>(props);
  ((void (*)(id, SEL, NSArray *))objc_msgSend)(self.nativeView, @selector(setData:), AMapCoordinateArray(value.data));
  [self.nativeView setValue:@((NSInteger)value.radius) forKey:@"radius"];
  [self.nativeView setValue:@(value.opacity) forKey:@"opacity"];
  [super updateProps:props oldProps:oldProps];
}
@end

Class<RCTComponentViewProtocol> AMapViewCls(void) { return AMapViewComponentView.class; }
Class<RCTComponentViewProtocol> AMapMarkerCls(void) { return AMapMarkerComponentView.class; }
Class<RCTComponentViewProtocol> AMapCircleCls(void) { return AMapCircleComponentView.class; }
Class<RCTComponentViewProtocol> AMapPolylineCls(void) { return AMapPolylineComponentView.class; }
Class<RCTComponentViewProtocol> AMapPolygonCls(void) { return AMapPolygonComponentView.class; }
Class<RCTComponentViewProtocol> AMapMultiPointCls(void) { return AMapMultiPointComponentView.class; }
Class<RCTComponentViewProtocol> AMapHeatMapCls(void) { return AMapHeatMapComponentView.class; }
