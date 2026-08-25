import type { ViewProps } from "react-native";
import type {
  BubblingEventHandler,
  Double,
  Int32,
} from "react-native/Libraries/Types/CodegenTypes";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";

type LatLng = Readonly<{
  latitude: Double;
  longitude: Double;
}>;

type ImageSource = Readonly<{
  uri: string;
  width?: Double;
  height?: Double;
  scale?: Double;
}>;

export interface NativeProps extends ViewProps {
  items?: ReadonlyArray<LatLng>;
  icon?: ImageSource;
  onPress?: BubblingEventHandler<Readonly<{ index: Int32 }>>;
}

export default codegenNativeComponent<NativeProps>("AMapMultiPoint");
