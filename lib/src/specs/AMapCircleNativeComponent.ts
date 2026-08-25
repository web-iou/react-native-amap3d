import type { ColorValue, ViewProps } from "react-native";
import type { Double } from "react-native/Libraries/Types/CodegenTypes";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";

type LatLng = Readonly<{
  latitude: Double;
  longitude: Double;
}>;

export interface NativeProps extends ViewProps {
  center: LatLng;
  radius: Double;
  strokeWidth?: Double;
  strokeColor?: ColorValue;
  fillColor?: ColorValue;
}

export default codegenNativeComponent<NativeProps>("AMapCircle");
