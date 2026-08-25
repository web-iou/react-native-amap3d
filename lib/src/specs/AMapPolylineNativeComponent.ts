import type { ColorValue, ViewProps } from "react-native";
import type {
  BubblingEventHandler,
  Double,
} from "react-native/Libraries/Types/CodegenTypes";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";

type LatLng = Readonly<{
  latitude: Double;
  longitude: Double;
}>;

export interface NativeProps extends ViewProps {
  points: ReadonlyArray<LatLng>;
  width?: Double;
  color?: ColorValue;
  colors?: ReadonlyArray<ColorValue>;
  gradient?: boolean;
  geodesic?: boolean;
  dotted?: boolean;
  dashed?: boolean;
  onPress?: BubblingEventHandler<Readonly<{}>>;
}

export default codegenNativeComponent<NativeProps>("AMapPolyline");
