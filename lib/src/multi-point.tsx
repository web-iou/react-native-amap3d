import * as React from "react";
import { Image, ImageSourcePropType, NativeSyntheticEvent } from "react-native";
import NativeMultiPoint from "./specs/AMapMultiPointNativeComponent";
import { LatLng } from "./types";

export interface MultiPointProps {
  /**
   * 坐标点集合
   */
  items?: LatLng[];

  /**
   * 图标
   */
  icon?: ImageSourcePropType;

  /**
   * 点击事件
   */
  onPress?: (event: NativeSyntheticEvent<{ index: number }>) => void;
}

export default (props: MultiPointProps) => {
  const { icon, ...rest } = props;
  return (
    <NativeMultiPoint {...rest} icon={icon ? Image.resolveAssetSource(icon) : undefined} />
  );
};
