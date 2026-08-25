import * as React from "react";
import { ColorValue, Platform, processColor, StyleProp, ViewStyle } from "react-native";
import NativePolyline from "./specs/AMapPolylineNativeComponent";
import { LatLng } from "./types";

export interface PolylineProps {
  /**
   * 节点坐标
   */
  points: LatLng[];

  /**
   * 线段宽度
   */
  width?: number;

  /**
   * 线段颜色
   */
  color?: ColorValue;

  /**
   * 层级（写入 style.zIndex，由原生 View 样式通道下发）
   */
  zIndex?: number;

  /**
   * 多段颜色
   */
  colors: ColorValue[];

  /**
   * 是否使用颜色渐变
   */
  gradient?: boolean;

  /**
   * 是否绘制大地线
   */
  geodesic?: boolean;

  /**
   * 是否绘制虚线
   */
  dotted?: boolean;

  /**
   * 点击事件
   */
  onPress?: () => void;

  style?: StyleProp<ViewStyle>;
}

export default class extends React.PureComponent<PolylineProps> {
  static defaultProps = { colors: [] };

  render() {
    const { dotted, colors, zIndex, style, ...rest } = this.props;
    const nativeColors =
      Platform.OS === "android"
        ? colors
            .map(processColor)
            .filter((color): color is Exclude<typeof color, null | undefined> => color != null)
        : colors;
    return (
      <NativePolyline
        {...rest}
        style={[style, zIndex != null ? { zIndex } : null]}
        colors={nativeColors as ColorValue[]}
        {...(Platform.OS === "android" ? { dashed: dotted } : { dotted })}
      />
    );
  }
}
