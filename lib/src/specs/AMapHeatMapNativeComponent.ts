import type { ViewProps } from "react-native";
import type { Double } from "react-native/Libraries/Types/CodegenTypes";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";

type LatLng = Readonly<{
  latitude: Double;
  longitude: Double;
}>;

export interface NativeProps extends ViewProps {
  data: ReadonlyArray<LatLng>;
  radius?: Double;
  opacity?: Double;
}

export default codegenNativeComponent<NativeProps>("AMapHeatMap");
