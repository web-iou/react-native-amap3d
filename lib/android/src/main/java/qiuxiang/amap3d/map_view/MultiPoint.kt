package qiuxiang.amap3d.map_view

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.amap.api.maps.AMap
import com.amap.api.maps.model.BitmapDescriptor
import com.amap.api.maps.model.MultiPointItem
import com.amap.api.maps.model.MultiPointOverlay
import com.amap.api.maps.model.MultiPointOverlayOptions
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.views.view.ReactViewGroup
import qiuxiang.amap3d.fetchImage
import qiuxiang.amap3d.toLatLng

class MultiPoint(context: Context) : ReactViewGroup(context), Overlay {
  private var map: AMap? = null
  private var overlay: MultiPointOverlay? = null
  private var items: List<MultiPointItem> = emptyList()
  private var icon: BitmapDescriptor? = null

  override fun add(map: AMap) {
    this.map = map
    addToMap()
  }

  override fun remove() {
    overlay?.destroy()
    overlay = null
    map = null
  }

  private fun addToMap() {
    val map = map ?: return
    val icon = icon ?: return
    if (overlay == null) {
      overlay = map.addMultiPointOverlay(MultiPointOverlayOptions().icon(icon))
    }
    overlay?.items = items
  }

  fun setItems(points: ReadableArray) {
    items = (0 until points.size())
      .map { item ->
        MultiPointItem(points.getMap(item)!!.toLatLng()).apply { customerId = "${id}_$item" }
      }
    overlay?.items = items
    addToMap()
  }

  fun setIcon(source: ReadableMap) {
    fetchImage(source) {
      Handler(Looper.getMainLooper()).post {
        icon = it
        overlay?.destroy()
        overlay = null
        addToMap()
      }
    }
  }
}
