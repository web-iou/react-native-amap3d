package qiuxiang.amap3d.modules

import com.amap.api.maps.AMapUtils
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import qiuxiang.amap3d.toLatLng

@Suppress("unused")
class MapUtils() : ReactContextBaseJavaModule() {
  override fun getName(): String {
    return "AMapUtils"
  }
  @ReactMethod(isBlockingSynchronousMethod = true)
  fun calculateLineDistance(startPoint: ReadableMap,endPoint: ReadableMap): Double {
      return AMapUtils.calculateLineDistance(startPoint.toLatLng(),endPoint.toLatLng()).toDouble()
  }
}
