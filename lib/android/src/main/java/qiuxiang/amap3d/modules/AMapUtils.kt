package qiuxiang.amap3d.modules

import com.amap.api.maps.AMapUtils
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.fbreact.specs.NativeAMapUtilsSpec
import qiuxiang.amap3d.toLatLng

@Suppress("unused")
class MapUtils(context: ReactApplicationContext) : NativeAMapUtilsSpec(context) {
  override fun calculateLineDistance(startPoint: ReadableMap,endPoint: ReadableMap): Double {
      return AMapUtils.calculateLineDistance(startPoint.toLatLng(),endPoint.toLatLng()).toDouble()
  }
}
