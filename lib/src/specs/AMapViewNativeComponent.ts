import type * as React from "react";
import type { HostComponent, ViewProps } from "react-native";
import type {
  BubblingEventHandler,
  DirectEventHandler,
  Double,
  Int32,
  WithDefault,
} from "react-native/Libraries/Types/CodegenTypes";
import codegenNativeCommands from "react-native/Libraries/Utilities/codegenNativeCommands";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";

type LatLng = Readonly<{
  latitude: Double;
  longitude: Double;
}>;

type CameraPosition = Readonly<{
  target?: LatLng;
  zoom?: Double;
  bearing?: Double;
  tilt?: Double;
}>;

type CameraEvent = Readonly<{
  cameraPosition: Readonly<{
    target?: Readonly<{
      latitude: Double;
      longitude: Double;
    }>;
    zoom?: Double;
    bearing?: Double;
    tilt?: Double;
  }>;
  latLngBounds: Readonly<{
    southwest: Readonly<{
      latitude: Double;
      longitude: Double;
    }>;
    northeast: Readonly<{
      latitude: Double;
      longitude: Double;
    }>;
  }>;
}>;

type MapPoi = Readonly<{
  id: string;
  name: string;
  position: Readonly<{
    latitude: Double;
    longitude: Double;
  }>;
}>;

type Location = Readonly<{
  timestamp: Double;
  coords: Readonly<{
    latitude: Double;
    longitude: Double;
    accuracy: Double;
    heading: Double;
    altitude: Double;
    speed: Double;
  }>;
}>;

type CallbackEvent = Readonly<{
  id: Double;
  data: Readonly<{
    latitude?: Double;
    longitude?: Double;
  }>;
}>;

export interface NativeProps extends ViewProps {
  mapType?: WithDefault<Int32, 0>;
  initialCameraPosition?: CameraPosition;
  cameraPosition?: LatLng;
  language?: string;
  /** 未传时须为 true：Codegen 对裸 boolean 默认 false，会关掉地图手势/标注 */
  myLocationEnabled?: WithDefault<boolean, false>;
  indoorViewEnabled?: WithDefault<boolean, false>;
  buildingsEnabled?: WithDefault<boolean, true>;
  labelsEnabled?: WithDefault<boolean, true>;
  compassEnabled?: WithDefault<boolean, true>;
  zoomControlsEnabled?: WithDefault<boolean, true>;
  scaleControlsEnabled?: WithDefault<boolean, true>;
  myLocationButtonEnabled?: WithDefault<boolean, false>;
  trafficEnabled?: WithDefault<boolean, false>;
  maxZoom?: Double;
  minZoom?: Double;
  zoomGesturesEnabled?: WithDefault<boolean, true>;
  scrollGesturesEnabled?: WithDefault<boolean, true>;
  rotateGesturesEnabled?: WithDefault<boolean, true>;
  tiltGesturesEnabled?: WithDefault<boolean, true>;
  distanceFilter?: Double;
  headingFilter?: Double;
  onPress?: BubblingEventHandler<LatLng>;
  onPressPoi?: BubblingEventHandler<MapPoi>;
  onLongPress?: BubblingEventHandler<LatLng>;
  onCameraMove?: BubblingEventHandler<CameraEvent>;
  onCameraIdle?: BubblingEventHandler<CameraEvent>;
  onLoad?: DirectEventHandler<Readonly<{}>>;
  onLocation?: BubblingEventHandler<Location>;
  onCallback?: BubblingEventHandler<CallbackEvent>;
}

type ComponentType = HostComponent<NativeProps>;

interface NativeCommands {
  moveCamera: (
    viewRef: React.ElementRef<ComponentType>,
    cameraPosition: string,
    duration: Double
  ) => void;
  call: (
    viewRef: React.ElementRef<ComponentType>,
    id: Double,
    name: string,
    args: string
  ) => void;
}

export const Commands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ["moveCamera", "call"],
});

export default codegenNativeComponent<NativeProps>("AMapView");
