package qiuxiang.amap3d

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.fbreact.specs.NativeAMapSdkSpec
import com.facebook.fbreact.specs.NativeAMapUtilsSpec
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.react.uimanager.ViewManager
import qiuxiang.amap3d.map_view.*
import qiuxiang.amap3d.modules.SdkModule
import qiuxiang.amap3d.modules.MapUtils

class AMap3DPackage : BaseReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return when (name) {
      NativeAMapSdkSpec.NAME -> SdkModule(reactContext)
      NativeAMapUtilsSpec.NAME -> MapUtils(reactContext)
      else -> null
    }
  }

  override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
    return listOf(
      MapViewManager(),
      MarkerManager(),
      PolylineManager(),
      PolygonManager(),
      CircleManager(),
      HeatMapManager(),
      MultiPointManager()
    )
  }

  override fun getReactModuleInfoProvider() = ReactModuleInfoProvider {
    mapOf(
      NativeAMapSdkSpec.NAME to ReactModuleInfo(
        NativeAMapSdkSpec.NAME,
        SdkModule::class.java.name,
        false,
        false,
        false,
        true
      ),
      NativeAMapUtilsSpec.NAME to ReactModuleInfo(
        NativeAMapUtilsSpec.NAME,
        MapUtils::class.java.name,
        false,
        false,
        false,
        true
      )
    )
  }
}
