package qiuxiang.amap3d.map_view

import android.content.Context
import com.amap.api.maps.AMap
import com.amap.api.maps.model.HeatmapTileProvider
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.TileOverlay
import com.amap.api.maps.model.TileOverlayOptions
import com.facebook.react.views.view.ReactViewGroup

class HeatMap(context: Context) : ReactViewGroup(context), Overlay {
  private var map: AMap? = null
  private var overlay: TileOverlay? = null
  private var data: List<LatLng> = emptyList()
  private var opacity: Double = 0.6
  private var radius: Int = 12

  override fun add(map: AMap) {
    this.map = map
    refresh()
  }

  private fun refresh() {
    val map = map ?: return
    overlay?.remove()
    overlay = null
    if (data.isEmpty()) return
    overlay = map.addTileOverlay(
      TileOverlayOptions().tileProvider(
        HeatmapTileProvider.Builder()
          .data(data)
          .radius(radius)
          .transparency(opacity)
          .build()
      )
    )
  }

  override fun remove() {
    overlay?.remove()
    overlay = null
    map = null
  }

  fun setData(value: List<LatLng>) {
    data = value
    refresh()
  }

  fun setOpacity(value: Double) {
    opacity = value
    refresh()
  }

  fun setRadius(value: Int) {
    radius = value
    refresh()
  }
}