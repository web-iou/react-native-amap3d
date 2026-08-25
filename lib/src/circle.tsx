import * as React from "react";
import type { StyleProp, ViewStyle } from "react-native";
import NativeCircle from "./specs/AMapCircleNativeComponent";
import { LatLng } from "./types";

export interface CircleProps {
  /**
   * 圆点坐标
   */
  center: LatLng;

  /**
   * 半径（米）
   */
  radius: number;

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

export default function Circle({ zIndex, style, ...props }: CircleProps) {
  return <NativeCircle {...props} style={[style, zIndex != null ? { zIndex } : null]} />;
}
