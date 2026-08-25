package qiuxiang.amap3d.modules

import com.amap.api.location.AMapLocationClient
import com.amap.api.maps.MapsInitializer
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.fbreact.specs.NativeAMapSdkSpec

@Suppress("unused")
class SdkModule(private val context: ReactApplicationContext) : NativeAMapSdkSpec(context) {
  override fun initSDK(apiKey: String?) {
    apiKey?.let {
      MapsInitializer.setApiKey(it)
      MapsInitializer.updatePrivacyAgree(context, true)
      MapsInitializer.updatePrivacyShow(context, true, true)
      AMapLocationClient.updatePrivacyAgree(context, true)
      AMapLocationClient.updatePrivacyShow(context, true, true)
    }
  }

  override fun getVersion(promise: Promise) {
    promise.resolve(MapsInitializer.getVersion())
  }
}
