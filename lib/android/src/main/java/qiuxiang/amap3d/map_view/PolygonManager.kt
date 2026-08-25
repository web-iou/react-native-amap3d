package qiuxiang.amap3d.map_view

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.AMapPolygonManagerDelegate
import com.facebook.react.viewmanagers.AMapPolygonManagerInterface
import qiuxiang.amap3d.toLatLngList
import qiuxiang.amap3d.toPx

@Suppress("unused")
internal class PolygonManager : SimpleViewManager<Polygon>(), AMapPolygonManagerInterface<Polygon> {
  private val delegate = AMapPolygonManagerDelegate<Polygon, PolygonManager>(this)

  override fun getDelegate(): ViewManagerDelegate<Polygon> = delegate
  override fun getName(): String {
    return "AMapPolygon"
  }

  override fun createViewInstance(reactContext: ThemedReactContext): Polygon {
    return Polygon(reactContext)
  }

  @ReactProp(name = "points")
  override fun setPoints(polygon: Polygon, points: ReadableArray?) {
    polygon.points = points?.toLatLngList() ?: emptyList()
  }

  @ReactProp(name = "fillColor", customType = "Color")
  override fun setFillColor(polygon: Polygon, fillColor: Int?) {
    polygon.fillColor = fillColor ?: 0
  }

  @ReactProp(name = "strokeColor", customType = "Color")
  override fun setStrokeColor(polygon: Polygon, strokeColor: Int?) {
    polygon.strokeColor = strokeColor ?: 0
  }

  @ReactProp(name = "strokeWidth")
  override fun setStrokeWidth(polygon: Polygon, strokeWidth: Double) {
    polygon.strokeWidth = strokeWidth.toFloat().toPx().toFloat()
  }

  override fun setZIndex(polygon: Polygon, zIndex: Float) {
    super.setZIndex(polygon, zIndex)
    polygon.zIndex = zIndex
  }
}
