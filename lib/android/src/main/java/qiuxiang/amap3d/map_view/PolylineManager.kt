package qiuxiang.amap3d.map_view

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.AMapPolylineManagerDelegate
import com.facebook.react.viewmanagers.AMapPolylineManagerInterface
import qiuxiang.amap3d.getEventTypeConstants
import qiuxiang.amap3d.toLatLngList
import qiuxiang.amap3d.toPx

@Suppress("unused")
internal class PolylineManager : SimpleViewManager<Polyline>(), AMapPolylineManagerInterface<Polyline> {
  private val delegate = AMapPolylineManagerDelegate<Polyline, PolylineManager>(this)

  override fun getDelegate(): ViewManagerDelegate<Polyline> = delegate
  override fun getName(): String {
    return "AMapPolyline"
  }

  override fun createViewInstance(context: ThemedReactContext): Polyline {
    return Polyline(context)
  }

  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
    return getEventTypeConstants("onPress")
  }

  @ReactProp(name = "points")
  override fun setPoints(polyline: Polyline, points: ReadableArray?) {
    polyline.points = points?.toLatLngList() ?: emptyList()
  }

  @ReactProp(name = "colors")
  override fun setColors(polyline: Polyline, colors: ReadableArray?) {
    polyline.colors = colors?.let { (0 until it.size()).map(it::getInt) } ?: emptyList()
  }

  @ReactProp(name = "color", customType = "Color")
  override fun setColor(polyline: Polyline, color: Int?) {
    polyline.color = color ?: 0
  }

  @ReactProp(name = "width")
  override fun setWidth(polyline: Polyline, width: Double) {
    polyline.width = width.toFloat().toPx().toFloat()
  }

  override fun setZIndex(polyline: Polyline, zIndex: Float) {
    super.setZIndex(polyline, zIndex)
    polyline.zIndex = zIndex
  }

  override fun setDotted(polyline: Polyline, dotted: Boolean) {
    polyline.dashed = dotted
  }

  @ReactProp(name = "geodesic")
  override fun setGeodesic(polyline: Polyline, geodesic: Boolean) {
    polyline.geodesic = geodesic
  }

  @ReactProp(name = "dashed")
  override fun setDashed(polyline: Polyline, dashed: Boolean) {
    polyline.dashed = dashed
  }

  @ReactProp(name = "gradient")
  override fun setGradient(polyline: Polyline, gradient: Boolean) {
    polyline.gradient = gradient
  }
}
