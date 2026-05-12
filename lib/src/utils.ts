import { NativeModules } from "react-native";
import { LatLng } from "./types";
const { AMapUtils } = NativeModules;
export function calculateLineDistance(startPoint: LatLng, endPoint: LatLng): number {
  return AMapUtils.calculateLineDistance(startPoint, endPoint);
}
