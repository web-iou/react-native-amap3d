package qiuxiang.amap3d.map_view

import android.view.View
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.AMapMarkerManagerDelegate
import com.facebook.react.viewmanagers.AMapMarkerManagerInterface
import qiuxiang.amap3d.getEventTypeConstants
import qiuxiang.amap3d.toLatLng

@Suppress("unused")
internal class MarkerManager : ViewGroupManager<Marker>(), AMapMarkerManagerInterface<Marker> {
  private val delegate = AMapMarkerManagerDelegate<Marker, MarkerManager>(this)
  override fun getName(): String {
    return "AMapMarker"
  }

  override fun getDelegate(): ViewManagerDelegate<Marker> = delegate

  override fun createViewInstance(reactContext: ThemedReactContext): Marker {
    return Marker(reactContext)
  }

  override fun addView(marker: Marker, view: View, index: Int) {
    super.addView(marker, view, index)
  }

  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
    return getEventTypeConstants("onPress", "onDrag", "onDragStart", "onDragEnd")
  }

  companion object {
    const val update = 1
  }

  override fun getCommandsMap(): Map<String, Int> {
    return mapOf("update" to update)
  }

  override fun receiveCommand(marker: Marker, commandId: Int, args: ReadableArray?) {
    when (commandId) {
      update -> marker.updateIcon()
    }
  }

  override fun receiveCommand(marker: Marker, commandId: String, args: ReadableArray?) {
    if (commandId == "update") marker.updateIcon()
  }

  override fun removeViewAt(parent: Marker, index: Int) {
    super.removeViewAt(parent, index)
    parent.updateIcon()
  }

  @ReactProp(name = "latLng")
  override fun setLatLng(view: Marker, position: ReadableMap?) {
    view.position = position?.toLatLng()
  }

  @ReactProp(name = "flat")
  override fun setFlat(marker: Marker, flat: Boolean) {
    marker.flat = flat
  }

  @ReactProp(name = "opacity")
  override fun setOpacity(marker: Marker, opacity: Float) {
    marker.opacity = opacity
  }

  override fun setOpacity(marker: Marker, opacity: Double) {
    marker.opacity = opacity.toFloat()
  }

  @ReactProp(name = "draggable")
  override fun setDraggable(marker: Marker, draggable: Boolean) {
    marker.draggable = draggable
  }

  override fun setZIndex(marker: Marker, zIndex: Float) {
    super.setZIndex(marker, zIndex)
    marker.zIndex = zIndex
  }

  @ReactProp(name = "anchor")
  override fun setAnchor(view: Marker, anchor: ReadableMap?) {
    anchor?.let { view.setAnchor(it.getDouble("x"), it.getDouble("y")) }
  }

  @ReactProp(name = "icon")
  override fun setIcon(view: Marker, icon: ReadableMap?) {
    icon?.let { view.setIcon(it) }
  }

  @ReactProp(name = "centerOffset")
  override fun setCenterOffset(view: Marker, centerOffset: ReadableMap?) = Unit

  override fun update(view: Marker) {
    view.updateIcon()
  }
}
