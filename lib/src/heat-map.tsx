import * as React from "react";
import NativeHeatMap from "./specs/AMapHeatMapNativeComponent";
import { LatLng } from "./types";

export interface HeatMapProps {
  /**
   * 节点坐标
   */
  data: LatLng[];

  /**
   * 半径（米）
   */
  radius?: number;

  /**
   * 透明度
   */
  opacity?: number;
}

export default function HeatMap(props: HeatMapProps) {
  return <NativeHeatMap {...props} />;
}
