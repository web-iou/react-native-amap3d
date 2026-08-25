package qiuxiang.amap3d.map_view

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.AMapMultiPointManagerDelegate
import com.facebook.react.viewmanagers.AMapMultiPointManagerInterface
import qiuxiang.amap3d.getEventTypeConstants

@Suppress("unused")
internal class MultiPointManager : SimpleViewManager<MultiPoint>(), AMapMultiPointManagerInterface<MultiPoint> {
  private val delegate = AMapMultiPointManagerDelegate<MultiPoint, MultiPointManager>(this)

  override fun getDelegate(): ViewManagerDelegate<MultiPoint> = delegate
  override fun getName(): String {
    return "AMapMultiPoint"
  }

  override fun createViewInstance(reactContext: ThemedReactContext): MultiPoint {
    return MultiPoint(reactContext)
  }

  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
    return getEventTypeConstants("onPress")
  }

  @ReactProp(name = "items")
  override fun setItems(multiPoint: MultiPoint, items: ReadableArray?) {
    items?.let(multiPoint::setItems)
  }

  @ReactProp(name = "icon")
  override fun setIcon(multiPoint: MultiPoint, icon: ReadableMap?) {
    icon?.let { multiPoint.setIcon(it) }
  }
}