import type * as React from "react";
import type { HostComponent, ViewProps } from "react-native";
import type {
  BubblingEventHandler,
  Double,
} from "react-native/Libraries/Types/CodegenTypes";
import codegenNativeCommands from "react-native/Libraries/Utilities/codegenNativeCommands";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";

type LatLng = Readonly<{
  latitude: Double;
  longitude: Double;
}>;

type Point = Readonly<{
  x: Double;
  y: Double;
}>;

type ImageSource = Readonly<{
  uri: string;
  width?: Double;
  height?: Double;
  scale?: Double;
}>;

export interface NativeProps extends ViewProps {
  latLng: LatLng;
  icon?: ImageSource;
  opacity?: Double;
  draggable?: boolean;
  flat?: boolean;
  anchor?: Point;
  centerOffset?: Point;
  onPress?: BubblingEventHandler<Readonly<{}>>;
  onDragStart?: BubblingEventHandler<Readonly<{}>>;
  onDrag?: BubblingEventHandler<Readonly<{}>>;
  onDragEnd?: BubblingEventHandler<LatLng>;
}

type ComponentType = HostComponent<NativeProps>;

interface NativeCommands {
  update: (viewRef: React.ElementRef<ComponentType>) => void;
}

export const Commands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ["update"],
});

export default codegenNativeComponent<NativeProps>("AMapMarker");
