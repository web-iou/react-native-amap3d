package qiuxiang.amap3d.map_view

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.AMapCircleManagerDelegate
import com.facebook.react.viewmanagers.AMapCircleManagerInterface
import qiuxiang.amap3d.toLatLng
import qiuxiang.amap3d.toPx

@Suppress("unused")
internal class CircleManager : SimpleViewManager<Circle>(), AMapCircleManagerInterface<Circle> {
  private val delegate = AMapCircleManagerDelegate<Circle, CircleManager>(this)

  override fun getDelegate(): ViewManagerDelegate<Circle> = delegate
  override fun getName(): String {
    return "AMapCircle"
  }

  override fun createViewInstance(reactContext: ThemedReactContext): Circle {
    return Circle(reactContext)
  }

  @ReactProp(name = "center")
  override fun setCenter(circle: Circle, center: ReadableMap?) {
    circle.center = center?.toLatLng()
  }

  @ReactProp(name = "radius")
  override fun setRadius(circle: Circle, radius: Double) {
    circle.radius = radius
  }

  @ReactProp(name = "fillColor", customType = "Color")
  override fun setFillColor(circle: Circle, fillColor: Int?) {
    circle.fillColor = fillColor ?: 0
  }

  @ReactProp(name = "strokeColor", customType = "Color")
  override fun setStrokeColor(circle: Circle, strokeColor: Int?) {
    circle.strokeColor = strokeColor ?: 0
  }

  @ReactProp(name = "strokeWidth")
  override fun setStrokeWidth(circle: Circle, strokeWidth: Double) {
    circle.strokeWidth = strokeWidth.toFloat().toPx().toFloat()
  }

  override fun setZIndex(circle: Circle, zIndex: Float) {
    super.setZIndex(circle, zIndex)
    circle.zIndex = zIndex
  }
}
