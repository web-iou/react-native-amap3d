package qiuxiang.amap3d.map_view

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.AMapHeatMapManagerDelegate
import com.facebook.react.viewmanagers.AMapHeatMapManagerInterface
import qiuxiang.amap3d.toLatLngList

@Suppress("unused")
internal class HeatMapManager : SimpleViewManager<HeatMap>(), AMapHeatMapManagerInterface<HeatMap> {
  private val delegate = AMapHeatMapManagerDelegate<HeatMap, HeatMapManager>(this)

  override fun getDelegate(): ViewManagerDelegate<HeatMap> = delegate
  override fun getName(): String {
    return "AMapHeatMap"
  }

  override fun createViewInstance(reactContext: ThemedReactContext): HeatMap {
    return HeatMap(reactContext)
  }

  @ReactProp(name = "data")
  override fun setData(heatMap: HeatMap, data: ReadableArray?) {
    heatMap.setData(data?.toLatLngList() ?: emptyList())
  }

  @ReactProp(name = "radius")
  override fun setRadius(heatMap: HeatMap, radius: Double) {
    heatMap.setRadius(radius.toInt())
  }

  @ReactProp(name = "opacity")
  override fun setOpacity(heatMap: HeatMap, opacity: Double) {
    heatMap.setOpacity(opacity)
  }
}