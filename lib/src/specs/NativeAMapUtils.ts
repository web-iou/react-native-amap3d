import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";
import type { Double } from "react-native/Libraries/Types/CodegenTypes";

type LatLng = Readonly<{
  latitude: Double;
  longitude: Double;
}>;

export interface Spec extends TurboModule {
  calculateLineDistance(startPoint: LatLng, endPoint: LatLng): Double;
}

export default TurboModuleRegistry.getEnforcing<Spec>("AMapUtils");
