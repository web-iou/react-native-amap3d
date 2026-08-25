import * as React from "react";
import type { StyleProp, ViewStyle } from "react-native";
import NativePolygon from "./specs/AMapPolygonNativeComponent";
import { LatLng } from "./types";

export interface Polygon {
  /**
   * 节点坐标
   */
  points: LatLng[];

  /**
   * 边线宽度
   */
  strokeWidth?: number;

  /**
   * 边线颜色
   */
  strokeColor?: string;

  /**
   * 填充颜色
   */
  fillColor?: string;

  /**
   * 层级（写入 style.zIndex，由原生 View 样式通道下发）
   */
  zIndex?: number;

  style?: StyleProp<ViewStyle>;
}

export default function PolygonView({ zIndex, style, ...props }: Polygon) {
  return <NativePolygon {...props} style={[style, zIndex != null ? { zIndex } : null]} />;
}
