package qiuxiang.amap3d.map_view

import android.view.View
import com.amap.api.maps.CameraUpdateFactory
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.AMapViewManagerDelegate
import com.facebook.react.viewmanagers.AMapViewManagerInterface
import qiuxiang.amap3d.getEventTypeConstants
import qiuxiang.amap3d.toLatLng

@Suppress("unused")
internal class MapViewManager : ViewGroupManager<MapView>(), AMapViewManagerInterface<MapView> {
  private val delegate = AMapViewManagerDelegate<MapView, MapViewManager>(this)
  private val commands = mapOf(
    "moveCamera" to { view: MapView, args: ReadableArray? ->
      if (args != null && args.size() >= 2) moveCamera(view, args.getString(0) ?: "{}", args.getDouble(1))
    },
    "call" to { view: MapView, args: ReadableArray? ->
      if (args != null && args.size() >= 3) {
        call(view, args.getDouble(0), args.getString(1) ?: "", args.getString(2) ?: "{}")
      }
    },
  )

  override fun getName(): String {
    return "AMapView"
  }

  override fun getDelegate(): ViewManagerDelegate<MapView> = delegate

  override fun createViewInstance(reactContext: ThemedReactContext): MapView {
    return MapView(reactContext)
  }

  override fun onDropViewInstance(view: MapView) {
    super.onDropViewInstance(view)
    view.destroy()
  }

  override fun getCommandsMap(): Map<String, Int> {
    return commands.keys.mapIndexed { index, key -> key to index }.toMap()
  }

  override fun receiveCommand(view: MapView, command: Int, args: ReadableArray?) {
    commands.values.elementAtOrNull(command)?.invoke(view, args)
  }

  override fun receiveCommand(view: MapView, command: String, args: ReadableArray?) {
    commands[command]?.invoke(view, args)
  }

  override fun addView(mapView: MapView, child: View, index: Int) {
    mapView.add(child)
    super.addView(mapView, child, index)
  }

  override fun removeViewAt(parent: MapView, index: Int) {
    parent.getChildAt(index)?.let(parent::remove)
    super.removeViewAt(parent, index)
  }

  override fun removeAllViews(parent: MapView) {
    for (index in parent.childCount - 1 downTo 0) {
      parent.getChildAt(index)?.let(parent::remove)
    }
    super.removeAllViews(parent)
  }

  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
    return getEventTypeConstants(
      "onLoad",
      "onPress",
      "onPressPoi",
      "onLongPress",
      "onCameraMove",
      "onCameraIdle",
      "onLocation",
      "onCallback",
    )
  }

  @ReactProp(name = "initialCameraPosition")
  override fun setInitialCameraPosition(view: MapView, position: ReadableMap?) {
    position?.let(view::setInitialCameraPosition)
  }

  @ReactProp(name = "myLocationEnabled")
  override fun setMyLocationEnabled(view: MapView, enabled: Boolean) {
    view.map.isMyLocationEnabled = enabled
  }

  @ReactProp(name = "indoorViewEnabled")
  override fun setIndoorViewEnabled(view: MapView, enabled: Boolean) {
    view.map.showIndoorMap(enabled)
  }

  @ReactProp(name = "buildingsEnabled")
  override fun setBuildingsEnabled(view: MapView, enabled: Boolean) {
    view.map.showBuildings(enabled)
  }

  @ReactProp(name = "labelsEnabled")
  override fun setLabelsEnabled(view: MapView, enabled: Boolean) {
    view.map.showMapText(enabled)
  }

  @ReactProp(name = "compassEnabled")
  override fun setCompassEnabled(view: MapView, show: Boolean) {
    view.map.uiSettings.isCompassEnabled = show
  }

  @ReactProp(name = "zoomControlsEnabled")
  override fun setZoomControlsEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isZoomControlsEnabled = enabled
  }

  @ReactProp(name = "scaleControlsEnabled")
  override fun setScaleControlsEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isScaleControlsEnabled = enabled
  }

  @ReactProp(name = "language")
  override fun setLanguage(view: MapView, language: String?) {
    language?.let(view.map::setMapLanguage)
  }

  @ReactProp(name = "myLocationButtonEnabled")
  override fun setMyLocationButtonEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isMyLocationButtonEnabled = enabled
  }

  @ReactProp(name = "trafficEnabled")
  override fun setTrafficEnabled(view: MapView, enabled: Boolean) {
    view.map.isTrafficEnabled = enabled
  }

  @ReactProp(name = "maxZoom")
  override fun setMaxZoom(view: MapView, zoomLevel: Double) {
    // Codegen 未传时为 0，写入会锁死缩放
    if (zoomLevel > 0) {
      view.map.maxZoomLevel = zoomLevel.toFloat()
    }
  }

  @ReactProp(name = "minZoom")
  override fun setMinZoom(view: MapView, zoomLevel: Double) {
    if (zoomLevel > 0) {
      view.map.minZoomLevel = zoomLevel.toFloat()
    }
  }

  @ReactProp(name = "mapType")
  override fun setMapType(view: MapView, mapType: Int) {
    view.map.mapType = mapType + 1
  }

  @ReactProp(name = "zoomGesturesEnabled")
  override fun setZoomGesturesEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isZoomGesturesEnabled = enabled
  }

  @ReactProp(name = "scrollGesturesEnabled")
  override fun setScrollGesturesEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isScrollGesturesEnabled = enabled
  }

  @ReactProp(name = "rotateGesturesEnabled")
  override fun setRotateGesturesEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isRotateGesturesEnabled = enabled
  }

  @ReactProp(name = "tiltGesturesEnabled")
  override fun setTiltGesturesEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isTiltGesturesEnabled = enabled
  }

  @ReactProp(name = "cameraPosition")
  override fun setCameraPosition(view: MapView, center: ReadableMap?) {
    center?.let { view.map.moveCamera(CameraUpdateFactory.changeLatLng(it.toLatLng())) }
  }

  @ReactProp(name = "distanceFilter")
  override fun setDistanceFilter(view: MapView, value: Double) = Unit

  @ReactProp(name = "headingFilter")
  override fun setHeadingFilter(view: MapView, value: Double) = Unit

  override fun moveCamera(view: MapView, cameraPosition: String, duration: Double) {
    view.moveCamera(cameraPosition, duration)
  }

  override fun call(view: MapView, id: Double, name: String, args: String) {
    view.call(id, name, args)
  }
}
