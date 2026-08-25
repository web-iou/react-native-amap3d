import AMapUtils from "./specs/NativeAMapUtils";
import { LatLng } from "./types";

export function calculateLineDistance(startPoint: LatLng, endPoint: LatLng): number {
  return AMapUtils.calculateLineDistance(startPoint, endPoint);
}
