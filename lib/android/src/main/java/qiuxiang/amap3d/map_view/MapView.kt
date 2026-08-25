package qiuxiang.amap3d.map_view

import android.annotation.SuppressLint
import android.view.View
import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.TextureMapView
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.MyLocationStyle
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.uimanager.ThemedReactContext
import qiuxiang.amap3d.dispatchEvent
import qiuxiang.amap3d.toJson
import qiuxiang.amap3d.toPx
import org.json.JSONObject

@SuppressLint("ViewConstructor")
class MapView(private val reactContext: ThemedReactContext) : TextureMapView(reactContext),
  LifecycleEventListener {
  private val markerMap = HashMap<String, qiuxiang.amap3d.map_view.Marker>()
  private val polylineMap = HashMap<String, Polyline>()
  private var initialCameraPosition: ReadableMap? = null
  private var locationStyle: MyLocationStyle
  private var destroyed = false

  init {
    super.onCreate(null)
    reactContext.addLifecycleEventListener(this)

    locationStyle = MyLocationStyle()
    locationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER)
    map.myLocationStyle = locationStyle

    map.setOnMapLoadedListener { emit(id, "onLoad") }
    map.setOnMapClickListener { latLng -> emit(id, "onPress", latLng.toJson()) }
    map.setOnPOIClickListener { poi -> emit(id, "onPressPoi", poi.toJson()) }
    map.setOnMapLongClickListener { latLng -> emit(id, "onLongPress", latLng.toJson()) }
    map.setOnPolylineClickListener { polyline -> emit(polylineMap[polyline.id]?.id, "onPress") }

    map.setOnMarkerClickListener { marker ->
      markerMap[marker.id]?.let { emit(it.id, "onPress") }
      true
    }

    map.setOnMarkerDragListener(object : AMap.OnMarkerDragListener {
      override fun onMarkerDragStart(marker: Marker) {
        emit(markerMap[marker.id]?.id, "onDragStart")
      }

      override fun onMarkerDrag(marker: Marker) {
        emit(markerMap[marker.id]?.id, "onDrag")
      }

      override fun onMarkerDragEnd(marker: Marker) {
        emit(markerMap[marker.id]?.id, "onDragEnd", marker.position.toJson())
      }
    })

    map.setOnCameraChangeListener(object : AMap.OnCameraChangeListener {
      override fun onCameraChangeFinish(position: CameraPosition) {
        emit(id, "onCameraIdle", Arguments.createMap().apply {
          putMap("cameraPosition", position.toJson())
          putMap("latLngBounds", map.projection.visibleRegion.latLngBounds.toJson())
        })
      }

      override fun onCameraChange(position: CameraPosition) {
        emit(id, "onCameraMove", Arguments.createMap().apply {
          putMap("cameraPosition", position.toJson())
          putMap("latLngBounds", map.projection.visibleRegion.latLngBounds.toJson())
        })
      }
    })

    map.setOnMultiPointClickListener { item ->
      item.customerId.split("_").let {
        emit(
          it[0].toInt(),
          "onPress",
          Arguments.createMap().apply { putInt("index", it[1].toInt()) },
        )
      }
      false
    }

    map.setOnMyLocationChangeListener {
      if (it.time > 0) {
        emit(id, "onLocation", it.toJson())
      }
    }
  }

  fun emit(id: Int?, event: String, data: WritableMap = Arguments.createMap()) {
    id?.let { dispatchEvent(reactContext, it, event, data) }
  }

  fun add(child: View) {
    if (child is Overlay) {
      child.add(map)
      if (child is qiuxiang.amap3d.map_view.Marker) {
        child.marker?.id?.let { markerMap[it] = child }
      }
      if (child is Polyline) {
        child.polyline?.id?.let { polylineMap[it] = child }
      }
    }
  }

  fun remove(child: View) {
    if (child is Overlay) {
      val markerId = (child as? qiuxiang.amap3d.map_view.Marker)?.marker?.id
      val polylineId = (child as? Polyline)?.polyline?.id
      child.remove()
      markerId?.let(markerMap::remove)
      polylineId?.let(polylineMap::remove)
    }
  }

  private val animateCallback = object : AMap.CancelableCallback {
    override fun onCancel() {}
    override fun onFinish() {}
  }

  fun moveCamera(cameraPosition: String, duration: Double) {
    val position = runCatching { JSONObject(cameraPosition) }.getOrNull() ?: return
    val current = map.cameraPosition
    val target = position.optJSONObject("target")?.let {
      com.amap.api.maps.model.LatLng(it.getDouble("latitude"), it.getDouble("longitude"))
    } ?: current.target
    val zoom = if (position.has("zoom")) position.getDouble("zoom").toFloat() else current.zoom
    val tilt = if (position.has("tilt")) position.getDouble("tilt").toFloat() else current.tilt
    val bearing = if (position.has("bearing")) position.getDouble("bearing").toFloat() else current.bearing
    val cameraUpdate = CameraUpdateFactory.newCameraPosition(
      CameraPosition(target, zoom, tilt, bearing)
    )
    if (duration > 0) {
      map.animateCamera(cameraUpdate, duration.toLong(), animateCallback)
    } else {
      map.moveCamera(cameraUpdate)
    }
  }

  fun setInitialCameraPosition(position: ReadableMap) {
    if (initialCameraPosition == null) {
      initialCameraPosition = position
      @Suppress("UNCHECKED_CAST")
      moveCamera(JSONObject(position.toHashMap() as Map<Any?, Any?>).toString(), 0.0)
    }
  }

  fun call(id: Double, name: String, args: String) {
    val arguments = runCatching { JSONObject(args) }.getOrNull() ?: return
    when (name) {
      "getLatLng" -> callback(
        id,
        map.projection.fromScreenLocation(
          android.graphics.Point(
            arguments.getDouble("x").toFloat().toPx(),
            arguments.getDouble("y").toFloat().toPx(),
          )
        ).toJson()
      )
    }
  }

  private fun callback(id: Double, data: Any) {
    emit(this.id, "onCallback", Arguments.createMap().apply {
      putDouble("id", id)
      when (data) {
        is WritableMap -> putMap("data", data)
      }
    })
  }

  override fun onHostResume() {
    onResume()
  }

  override fun onHostPause() {
    onPause()
  }

  override fun onHostDestroy() {
    destroy()
  }

  fun destroy() {
    if (destroyed) return
    destroyed = true
    reactContext.removeLifecycleEventListener(this)
    for (index in childCount - 1 downTo 0) {
      (getChildAt(index) as? Overlay)?.remove()
    }
    markerMap.clear()
    polylineMap.clear()
    onDestroy()
  }
}
